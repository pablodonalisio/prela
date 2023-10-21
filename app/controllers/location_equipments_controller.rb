class LocationEquipmentsController < ApplicationController
  def new
    @location_equipment = LocationEquipment.new
    @equipments = Equipment.all
    client
  end

  def create
    @location_equipment = LocationEquipment.new(location_equipment_params)

    if @location_equipment.save
      respond_to do |format|
        format.html { redirect_to client_path(client), notice: "Se ha agregado un nuevo equipo a la sede." }
        format.turbo_stream { flash.now[:notice] = "Se ha agregado un nuevo equipo a la sede." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def location_equipment_params
    params.require(:location_equipment).permit(:zone, :floor, :location_id, :equipment_id)
  end

  def client
    @client ||= Client.find(params[:client_id])
  end
end
