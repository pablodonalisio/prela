class LocationEquipmentsController < ApplicationController
  before_action :equipments, only: %i[new edit update destroy]
  before_action :client
  before_action :location_equipment, only: %i[edit update destroy]

  def new
    @location_equipment = LocationEquipment.new
  end

  def edit
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

  def update
    if @location_equipment.update(location_equipment_params)
      respond_to do |format|
        format.html { redirect_to client_path(client), notice: "Se ha actualizado el equipo de la sede." }
        format.turbo_stream { flash.now[:notice] = "Se ha actualizado el equipo de la sede." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @location_equipment.destroy

    respond_to do |format|
      format.html { redirect_to client_path(client), notice: "El equipo de la sede ha sido eliminado." }
      format.turbo_stream { flash.now[:notice] = "El equipo de la sede ha sido eliminado." }
    end
  end

  private

  def location_equipment_params
    params.require(:location_equipment).permit(:zone, :floor, :location_id, :equipment_id)
  end

  def client
    @client ||= Client.find(params[:client_id])
  end

  def equipments
    @equipments ||= Equipment.all
  end

  def location_equipment
    @location_equipment ||= LocationEquipment.find(params[:id])
  end
end
