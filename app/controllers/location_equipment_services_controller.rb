class LocationEquipmentServicesController < ApplicationController
  before_action :set_location_equipment
  before_action :set_location_equipment_service, only: %i[edit update destroy]

  def new
    @location_equipment_service = authorize @location_equipment.location_equipment_services.build
    first_kind = @location_equipment.available_service_kinds_for_assignment.first
    if first_kind
      @location_equipment_service.service_kind = first_kind
      @location_equipment_service.apply_service_kind_defaults!
    end
    @location_equipment_service.due_on = Date.current
  end

  def create
    @location_equipment_service = authorize @location_equipment.location_equipment_services.build(create_params.except(:due_on))
    @location_equipment_service.due_on = create_params[:due_on]

    if @location_equipment_service.due_on.blank?
      @location_equipment_service.errors.add(:due_on, :blank)
      render :new, status: :unprocessable_entity
      return
    end

    if @location_equipment_service.save
      @location_equipment_service.create_pending_occurrence!
      respond_to do |format|
        format.html { redirect_to @location_equipment, notice: "El servicio se asignó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El servicio se asignó correctamente." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @location_equipment_service.update(update_params)
      respond_to do |format|
        format.html { redirect_to @location_equipment, notice: "El servicio se actualizó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El servicio se actualizó correctamente." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location_equipment_service.destroy!
    respond_to do |format|
      format.html { redirect_to @location_equipment, notice: "El servicio se eliminó correctamente.", status: :see_other }
      format.turbo_stream { flash.now[:notice] = "El servicio se eliminó correctamente." }
    end
  end

  private

  def set_location_equipment
    @location_equipment = LocationEquipment.find(params[:location_equipment_id])
  end

  def set_location_equipment_service
    @location_equipment_service = authorize @location_equipment.location_equipment_services.find(params[:id])
  end

  def create_params
    params.require(:location_equipment_service).permit(:service_kind_id, :interval, :interval_unit, :due_on)
  end

  def update_params
    params.require(:location_equipment_service).permit(:interval, :interval_unit)
  end
end
