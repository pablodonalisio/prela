class LocationEquipmentsController < ApplicationController
  before_action :location_equipment, only: %i[edit update destroy]
  before_action :set_locations, only: %i[edit]

  def new
    @location_equipment = LocationEquipment.new
    @locations = Location.where(client_id: params[:client_id])
  end

  def index
    @location_equipments = LocationEquipment.filter(filter_params).includes(:equipment, location: :client)
  end

  def show
    @location_equipment = LocationEquipment.find(params[:id])
  end

  def edit
    @edition = params[:edition]
  end

  def create
    create_location_equipment

    if @location_equipment.save
      respond_to do |format|
        format.html { redirect_to location_equipments_path, notice: "Se ha agregado un nuevo equipo a la sede." }
        format.turbo_stream {}
      end
    else
      set_locations
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @location_equipment.update(location_equipment_params)
      respond_to do |format|
        format.html { redirect_to location_equipments_path, notice: "Se ha actualizado el equipo de la sede." }
        format.turbo_stream {}
      end
    else
      set_locations
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location_equipment.destroy

    respond_to do |format|
      format.html { redirect_to location_equipments_path, notice: "El equipo de la sede ha sido eliminado." }
      format.turbo_stream {}
    end
  end

  private

  def location_equipment_params
    params.require(:location_equipment)
      .permit(:zone, :floor, :location_id, :equipment_id, :serial_number,
        :last_service, :next_service, :last_battery_change, :next_battery_change, :details)
  end

  def location_equipment
    @location_equipment ||= LocationEquipment.find(params[:id])
  end

  def set_locations
    @locations = Location.where(client_id: @location_equipment.location&.client_id)
  end

  def filter_params
    filters = %i[client_ids]
    filters << :location_ids if params[:client_ids]&.compact_blank!.present?
    @filter_params = params.slice(*filters)
  end

  def create_location_equipment
    @location_equipment = LocationEquipment.new(location_equipment_params)
    @location_equipment.battery = @location_equipment.equipment.battery
  end
end
