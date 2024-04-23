class ReportsController < ApplicationController
  def index
    @reports = location_equipment.reports.order(created_at: :desc)
  end

  def show
    @report = Report.find(params[:id])
  end

  def new
    @report = location_equipment.reports.build
    @report.build_ups_report_stat
    @report.build_room_report_stat
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
end
