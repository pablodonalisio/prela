class LocationEquipmentsController < ApplicationController
  before_action :location_equipment, only: %i[edit update destroy]
  before_action :set_order, only: :index

  def new
    @location_equipment = authorize LocationEquipment.new
  end

  def index
    scoped = policy_scope(
      LocationEquipment.filter(filter_params)
        .includes(equipment: :avatar_blob, location: :client)
        .order(@order)
    )
    authorize scoped
    @pagy, @location_equipments = pagy(scoped)
  end

  def show
    @location_equipment = authorize LocationEquipment.visible.find(params[:id])
  end


  def edit
  end

  def create
    create_location_equipment

    if @location_equipment.save
      respond_to do |format|
        format.html { redirect_to location_equipments_path, notice: "Se ha agregado un nuevo equipo a la sede." }
        format.turbo_stream {}
      end
    else
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
      render :edit, status: :unprocessable_entity
    end
  end

  def location_inputs
    @client = Client.visible.find_by(id: params[:client_id])
    @locations = @client ? Location.visible.where(client_id: @client.id) : Location.none
    @selected_location_id = params[:location_id].presence
  end

  def field_inputs
    equipment = Equipment.visible.find_by(id: params[:equipment_id])
    @equipment_kind = equipment&.equipment_kind
    existing = LocationEquipment.visible.find_by(id: params[:location_equipment_id])
    @field_values = existing&.field_values || {}
  end

  def destroy
    @location_equipment.discard!

    respond_to do |format|
      format.html { redirect_to location_equipments_path, notice: "El equipo de la sede ha sido eliminado." }
      format.turbo_stream {}
    end
  end


  private

  def location_equipment_params
    params.require(:location_equipment)
      .permit(:zone, :floor, :location_id, :equipment_id, :status, :condition, :details,
        :serial_number, :code, :form_link,
        :last_service, :next_service, :last_battery_change, :next_battery_change,
        :last_belt_change, :next_belt_change, :engine_serial_number, :power_unit_serial_number, :service_interval,
        :battery_change_interval, :belt_change_interval, :torque_interval, :last_torque, :next_torque,
        :cleaning_interval, :last_cleaning, :next_cleaning, :srt_900_interval, :last_srt_900, :next_srt_900,
        :thermography_interval, :last_thermography, :next_thermography,
        :electrical_approval_interval, :last_electrical_approval, :next_electrical_approval,
        field_values: {},
        report_template_ids: [])
  end

  def location_equipment
    @location_equipment ||= authorize LocationEquipment.visible.find(params[:id])
  end

  def filter_params
    set_client_id_filter if current_user.client?
    add_location_ids_filter if any_client_selected?

    @filter_params = params.slice(*filters)
  end

  def filters
    @filters ||= %i[client_ids status equipment_kind_ids]
  end

  def add_location_ids_filter
    filters << :location_ids
  end

  def any_client_selected?
    params[:client_ids]&.compact_blank!.present?
  end

  def set_client_id_filter
    params[:client_ids] = [current_user.client_id.to_s]
  end

  def create_location_equipment
    @location_equipment = authorize LocationEquipment.new(location_equipment_params)
    @location_equipment.battery = @location_equipment.equipment&.battery
  end

  def set_order
    @order = params[:order] || "next_service"
  end
end
