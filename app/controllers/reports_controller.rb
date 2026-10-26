class ReportsController < ApplicationController
  helper_method :report_signatures

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
    @report_mode = if template_create?
      "template"
    elsif upload_create?
      "upload"
    else
      "legacy"
    end
    @report = authorize location_equipment.reports.build
    prepare_report_signatures
    assign_report_attributes
    attach_uploaded_files if upload_mode?

    if @report.save
      location_equipment.associate_report_template!(@report.report_template) if @report.template_based? && @report.report_template
      return report_pdf_error if legacy_mode? && !attach_pdf

      respond_to do |format|
        format.html { redirect_to location_equipment_reports_path(location_equipment), notice: "El informe se creó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El informe se creó correctamente." }
      end
    else
      load_template_form_data if template_mode?
      build_report_stats if legacy_mode? && @report.room_report_stat.nil?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @report = authorize report
    preload_template_sections if @report.template_based?
    load_template_form_data if @report.template_based?
  end

  def update
    @report = authorize report
    prepare_report_signatures
    @report.section_inputs = section_inputs_param if @report.template_based?

    if save_report_update
      purge_removed_images unless @report.uploaded?
      purge_removed_uploaded_files if @report.uploaded?
      location_equipment.associate_report_template!(@report.report_template) if @report.template_based? && @report.report_template
      return report_pdf_error if legacy_mode? && !attach_pdf

      respond_to do |format|
        format.html { redirect_to location_equipment_reports_path(location_equipment), notice: "El informe se editó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El informe se editó correctamente." }
      end
    else
      load_template_form_data if @report.template_based?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    flash.now[:notice] = "El informe ha sido eliminado." if report.destroy
  end

  def template_fields
    authorize Report.new(location_equipment: location_equipment), :new?
    @report_template = ReportTemplate.find(params[:report_template_id])
    @report = report_for_template_fields
    @report.report_template = @report_template
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
      @report.section_inputs = section_inputs_param
    elsif upload_create? || (@report.persisted? && @report.uploaded?)
      @report.assign_attributes(upload_report_params)
    else
      @report.assign_attributes(legacy_report_params)
    end
  end

  def report_update_params
    if @report.template_based?
      template_report_params
    elsif @report.uploaded?
      upload_report_params
    else
      legacy_report_params
    end
  end

  def template_create?
    params.dig(:report, :report_template_id).present?
  end

  def upload_create?
    ActiveModel::Type::Boolean.new.cast(params.dig(:report, :uploaded))
  end

  def report_mode_param
    params[:report_mode].in?(%w[template legacy upload]) ? params[:report_mode] : "legacy"
  end

  def upload_mode?
    @report_mode == "upload" || @report&.uploaded?
  end

  def template_mode?
    return false if upload_mode?

    @report_mode == "template" || (@report&.template_based? && !@report.new_record?)
  end

  def legacy_mode?
    !template_mode? && !upload_mode?
  end

  def load_template_form_data
    @associated_templates = location_equipment.report_templates.order(:name)
    @all_templates = ReportTemplate.order(:name)
    return if @report.persisted?

    @report.report_template ||= @associated_templates.first || @all_templates.first
  end

  def preload_template_sections
    return if @report.sections.loaded?

    @report.sections.with_details.load
  end

  def shared_report_params
    params.require(:report).permit(:observations, :date, images: [])
  end

  def upload_report_params
    permitted = [:date]
    permitted << :uploaded unless @report&.persisted?
    params.require(:report).permit(*permitted)
  end

  def save_report_update
    return @report.update(report_update_params) unless @report.uploaded?

    @report.assign_attributes(upload_report_params)
    attach_uploaded_files
    @report.removed_file_blob_ids = removed_uploaded_file_ids
    @report.save
  end

  def uploaded_files
    Array(params.dig(:report, :files)).compact_blank
  end

  def removed_uploaded_file_ids
    Array(params.dig(:report, :removed_file_ids)).compact_blank
  end

  def attach_uploaded_files
    return if uploaded_files.empty?

    @report.files.attach(uploaded_files)
  end

  def purge_removed_uploaded_files
    return if removed_uploaded_file_ids.empty?

    @report.files.where(blob_id: removed_uploaded_file_ids).find_each(&:purge)
    @report.files.reload
  end

  def template_report_params
    params.require(:report).permit(
      :date,
      :report_template_id,
      signature_ids: []
    )
  end

  def section_inputs_param
    raw = params.dig(:report, :section_inputs)
    return {} if raw.blank?

    raw.to_unsafe_h.each_with_object({}) do |(section_id, values), result|
      next unless section_id.to_s.match?(/\A\d+\z/)

      values = values.to_h.stringify_keys
      payload = {}
      payload["body"] = values["body"].to_s if values.key?("body")
      payload["images"] = extract_section_images(values["images"]) if values.key?("images")
      payload["removed_image_ids"] = Array(values["removed_image_ids"]).map(&:to_s).reject(&:blank?) if values.key?("removed_image_ids")
      payload["cells"] = extract_section_cells(values["cells"]) if values.key?("cells")
      payload["items"] = extract_section_items(values["items"]) if values.key?("items")
      result[section_id.to_s] = payload
    end
  end

  def extract_section_images(images)
    Array(images).select { |image| image.present? }
  end

  def extract_section_items(items)
    return {} if items.blank?

    items.to_h.each_with_object({}) do |(id, item), result|
      next unless id.to_s.match?(/\A\d+\z/)

      result[id.to_s] = {"checked" => item.to_h.stringify_keys["checked"].to_s}
    end
  end

  def extract_section_cells(cells)
    return {} if cells.blank?

    cells.to_h.each_with_object({}) do |(key, cell), result|
      next unless key.to_s.match?(/\A\d+_\d+\z/)

      result[key.to_s] = {"value" => cell.to_h.stringify_keys["value"].to_s}
    end
  end

  def report_signatures
    policy_scope(Signature, policy_scope_class: SignaturePolicy::ReportScope)
  end

  def prepare_report_signatures
    return unless template_create? || @report.template_based?

    @report.allowed_signatures = report_signatures
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
