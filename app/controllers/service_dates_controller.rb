class ServiceDatesController < ApplicationController
  def show
    @service_date = authorize ServiceDate.find(params[:id])
  end

  def edit
    @service_date = authorize ServiceDate.find(params[:id])
  end

  def update
    @service_date = authorize ServiceDate.find(params[:id])

    if @service_date.update(service_date_params)
      respond_to do |format|
        format.html { redirect_to location_equipment_path(location_equipment), notice: "La fecha de servicio se actualizó correctamente." }
        format.turbo_stream { flash.now[:notice] = "La fecha de servicio se actualizó correctamente." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def service_date_params
    params.require(:service_date).permit(:date)
  end
end
