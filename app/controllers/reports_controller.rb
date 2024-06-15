class ReportsController < ApplicationController
  before_action lambda {
    resize_before_save(params[:report][:images], nil, 250)
  }, only: %i[create update]

  def index
    @reports = location_equipment.reports.order(created_at: :desc)
  end

  def show
    @report = Report.find(params[:id])
  end

  def new
    @report = location_equipment.reports.build
    build_report_stats
  end

  def create
    @report = location_equipment.reports.build(report_params)

    if @report.save
      return report_pdf_error unless attach_pdf

      respond_to do |format|
        format.html { redirect_to location_equipment_reports_path(location_equipment), notice: "El reporte se creo correctamente." }
        format.turbo_stream { flash.now[:notice] = "El reporte se creo correctamente." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @report = location_equipment.reports.find(params[:id])
  end

  def update
    @report = location_equipment.reports.find(params[:id])

    if @report.update(report_params)
      return report_pdf_error unless attach_pdf

      respond_to do |format|
        format.html { redirect_to location_equipment_reports_path(location_equipment), notice: "El reporte se edito correctamente." }
        format.turbo_stream { flash.now[:notice] = "El reporte se edito correctamente." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    flash.now[:notice] = "El reporte ha sido eliminado." if location_equipment.reports.find(params[:id]).destroy
  end

  private

  def location_equipment
    @location_equipment ||= LocationEquipment.find(params[:location_equipment_id])
  end

  def report_params
    params.require(:report)
      .permit(
        :observations, :date,
        ups_report_stat_attributes: %i[
          operating_mode
          associated_charge
          battery_charge
          voltage_input
          voltage_output
          pat_state
          alarms_presence
          ventilation_state
        ],
        power_unit_report_stat_attributes: %i[
          equipment_power
          start_key_on_auto
          rpm
          frequency
          battery_charge_control
          tension_between_phases_a_b
          tension_between_phases_b_c
          tension_between_phases_c_a
          initial_temperature
          running_temperature
          number_of_starts
          operating_time
          failed_starts
          oil_pressure
          fuel_level
          coolant_level
          oil_level
          testing_time
          general_disconnector
          emergency_stop_position
        ],
        room_report_stat_attributes: %i[
          room_status
          air_conditioning
        ],
        images: []
      )
  end

  def attach_pdf
    return unless pdf_content.success?

    @report.pdf.attach(
      io: StringIO.new(pdf_content.pdf),
      filename: "#{location_equipment.model}_report.pdf",
      content_type: "application/pdf"
    )
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

  def resize_before_save(images, width, height)
    return unless images.present?

    begin
      images.each do |image|
        next unless image&.is_a?(ActionDispatch::Http::UploadedFile)
        ImageProcessing::MiniMagick
          .source(image)
          .resize_to_limit(width, height)
          .call(destination: image.tempfile.path)
      end
    rescue => _e
      # Do nothing. If this is catching, it probably means the
      # file type is incorrect, which can be caught later by
      # model validations.
    end
  end

  def build_report_stats
    @report.build_ups_report_stat if location_equipment.equipment.ups?
    @report.build_power_unit_report_stat if location_equipment.equipment.power_unit?
    @report.build_room_report_stat
  end
end
