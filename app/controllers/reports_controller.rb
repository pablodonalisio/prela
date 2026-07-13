class ReportsController < ApplicationController
  before_action :set_reports, only: %i[index destroy update]

  def index
    @reports = authorize location_equipment.reports.order(created_at: :desc)
  end

  def show
    @report = authorize Report.find(params[:id])
  end

  def new
    @report = authorize location_equipment.reports.build
    @report_mode = report_mode_param
    load_template_form_data if template_mode?
    build_report_stats if legacy_mode?
  end

  def create
    @report_mode = template_create? ? "template" : "legacy"
    @report = authorize location_equipment.reports.build
    assign_report_attributes

    if @report.save
      location_equipment.associate_report_template!(@report.report_template) if @report.template_based?
      return report_pdf_error if legacy_mode? && !attach_pdf

      respond_to do |format|
        format.html { redirect_to location_equipment_reports_path(location_equipment), notice: "El reporte se creo correctamente." }
        format.turbo_stream { flash.now[:notice] = "El reporte se creo correctamente." }
      end
    else
      load_template_form_data if template_mode?
      build_report_stats if legacy_mode? && @report.room_report_stat.nil?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @report = authorize report
    load_template_form_data if @report.template_based?
  end

  def update
    @report = authorize report

    if @report.update(report_update_params)
      purge_removed_images
      location_equipment.associate_report_template!(@report.report_template) if @report.template_based?
      return report_pdf_error if !@report.template_based? && !attach_pdf

      respond_to do |format|
        format.html { redirect_to location_equipment_reports_path(location_equipment), notice: "El reporte se edito correctamente." }
        format.turbo_stream { flash.now[:notice] = "El reporte se edito correctamente." }
      end
    else
      load_template_form_data if @report.template_based?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    flash.now[:notice] = "El reporte ha sido eliminado." if report.destroy
  end

  def template_fields
    authorize Report.new(location_equipment: location_equipment), :new?
    @report_template = ReportTemplate.find(params[:report_template_id])
    @report = report_for_template_fields
    @report.report_template = @report_template
    @report.build_tasks_from_template! if @report.new_record?

    render :template_fields, layout: false
  end

  private

  def location_equipment
    @location_equipment ||= LocationEquipment.find(params[:location_equipment_id])
  end

  def report
    @report ||= authorize location_equipment.reports.find(params[:id])
  end

  def report_for_template_fields
    if params[:report_id].present?
      location_equipment.reports.find_by(id: params[:report_id]) || location_equipment.reports.build
    else
      location_equipment.reports.build(report_template: @report_template)
    end
  end

  def assign_report_attributes
    if template_create? || (@report.persisted? && @report.template_based?)
      @report.assign_attributes(template_report_params)
    else
      @report.assign_attributes(legacy_report_params)
    end
  end

  def report_update_params
    if @report.template_based?
      template_report_params
    else
      legacy_report_params
    end
  end

  def template_create?
    params.dig(:report, :report_template_id).present?
  end

  def report_mode_param
    params[:report_mode].in?(%w[template legacy]) ? params[:report_mode] : "legacy"
  end

  def template_mode?
    @report_mode == "template" || (@report&.template_based? && !@report.new_record?)
  end

  def legacy_mode?
    !template_mode?
  end

  def load_template_form_data
    @associated_templates = location_equipment.report_templates.order(:name)
    @all_templates = ReportTemplate.order(:name)
    @report.report_template ||= @associated_templates.first || @all_templates.first
    return unless @report.new_record? && @report.report_template.present? && @report.report_tasks.empty?

    @report.build_tasks_from_template!
  end

  def shared_report_params
    params.require(:report).permit(:observations, :date, images: [])
  end

  def template_report_params
    permitted = params.require(:report).permit(
      :observations,
      :date,
      :report_template_id,
      field_values: {
        equipment_specifications: {},
        location_specifications: {},
        measurements: {},
        room_specifications: {}
      },
      report_tasks_attributes: %i[id name completed position _destroy],
      images: []
    )

    ReportTemplate::SECTIONS.each do |section|
      permitted[:field_values] ||= {}
      permitted[:field_values][section] ||= {}
    end

    permitted
  end

  def legacy_report_params
    params.require(:report)
      .permit(
        :observations, :date,
        ups_report_stat_attributes: %i[
          id operating_mode associated_charge battery_charge voltage_input voltage_output
          voltage_input_l1 voltage_input_l2 voltage_input_l3
          voltage_output_l1 voltage_output_l2 voltage_output_l3
          pat_state alarms_presence ventilation_state
        ],
        power_unit_report_stat_attributes: %i[
          id start_key_on_auto rpm frequency battery_charge_control
          tension_between_phases_a_b tension_between_phases_b_c tension_between_phases_c_a
          initial_temperature running_temperature number_of_starts operating_time failed_starts
          oil_pressure oil_pressure_unit fuel_level coolant_level oil_level testing_time
          general_disconnector emergency_stop_position lamp_test belt_condition
          air_filter_condition anti_vibration_pad_condition liquids_leaks
          connections_condition_and_battery_fixation cable_and_electrical_connections
        ],
        electrical_panel_report_stat_attributes: [:id] + ElectricalPanelReportStat.permitted_attributes,
        room_report_stat_attributes: [:id] + RoomReportStat.permitted_attributes,
        images: []
      )
  end

  def attach_pdf
    return false unless pdf_content.success?

    @report.pdf.attach(
      io: StringIO.new(pdf_content.pdf),
      filename: "#{report_filename}.pdf",
      content_type: "application/pdf"
    )
    true
  end

  def report_filename
    "Informe preventivo de #{location_equipment.code} - #{l(@report.date.to_date)}"
  end

  def pdf_content
    @pdf_content ||= Reports::PdfGenerator.call(@report)
  end

  def report_pdf_error
    @report.errors.add(:pdf, pdf_content.error)

    respond_to do |format|
      format.html { redirect_to location_equipment_reports_path(location_equipment), error: @report.errors.full_messages.to_sentence }
      format.turbo_stream { flash.now[:error] = "Error: #{@report.errors.full_messages.to_sentence}" }
    end
  end

  def purge_removed_images
    removed_ids = params.dig(:report, :removed_image_ids) || []
    return if removed_ids.blank?

    @report.images.where(blob_id: removed_ids).find_each(&:purge)
    @report.reload
  end

  def build_report_stats
    @report.build_ups_report_stat if location_equipment.equipment.ups?
    @report.build_power_unit_report_stat if location_equipment.equipment.power_unit?
    @report.build_electrical_panel_report_stat if location_equipment.equipment.electrical_panel?
    @report.build_room_report_stat
  end

  def set_reports
    @reports = location_equipment.reports.order(date: :desc)
  end
end
