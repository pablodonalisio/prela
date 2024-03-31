class ReportsController < ApplicationController
  def show
    @report = Report.find(params[:id])
  end

  def new
    @report = location_equipment.reports.build
  end

  def create
    @report = location_equipment.reports.build(report_params)

    if @report.save
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
    params.require(:report).permit(:observations)
  end
end
