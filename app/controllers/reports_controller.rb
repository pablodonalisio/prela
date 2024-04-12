class ReportsController < ApplicationController
  def show
    @report = Report.find(params[:id])
  end

  def new
    @report = location_equipment.reports.build
    @report.build_ups_report_stat
  end

  def create
    @report = location_equipment.reports.build(report_params)
    pdf_content = Reports::PdfGenerator.call(@report)

    if pdf_content.success? && @report.save
      @report.pdf.attach(io: StringIO.new(pdf_content.pdf), filename: "#{location_equipment.model}_report.pdf", content_type: "application/pdf")
      respond_to do |format|
        format.html { redirect_to location_equipment_reports_path(location_equipment), notice: "Report was successfully created." }
        format.turbo_stream {}
      end
    else
      render :new
    end
  end

  def edit
    @report = location_equipment.reports.find(params[:id])
  end

  def update
    @report = location_equipment.reports.find(params[:id])

    render :edit unless @report.update(report_params)
  end

  def destroy
    location_equipment.reports.find(params[:id]).destroy
  end

  private

  def location_equipment
    @location_equipment ||= LocationEquipment.find(params[:location_equipment_id])
  end

  def report_params
    params.require(:report)
      .permit(
        :observations,
        ups_report_stat_attributes: %i[
          operating_mode
          associated_charge
          battery_charge
          voltage_input
          voltage_output
          pat_state
          alarms_presence
          ventilation_state
        ]
      )
  end
end
