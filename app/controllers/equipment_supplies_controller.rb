class EquipmentSuppliesController < ApplicationController
  before_action :set_equipment_supply, only: %i[edit update destroy]

  def new
    @equipment_supply = authorize EquipmentSupply.new(location_equipment: location_equipment_from_params)
  end

  def edit
  end

  def create
    @equipment_supply = authorize EquipmentSupply.new(equipment_supply_params)

    respond_to do |format|
      if @equipment_supply.save
        format.html { redirect_to @equipment_supply.location_equipment, notice: "Se ha agregado el insumo al equipo." }
        format.turbo_stream { render_supplies_list "Se ha agregado el insumo al equipo." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @equipment_supply.update(equipment_supply_params)
        format.html { redirect_to @equipment_supply.location_equipment, notice: "El insumo se actualizó correctamente.", status: :see_other }
        format.turbo_stream { render_supplies_list "El insumo se actualizó correctamente." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @location_equipment = @equipment_supply.location_equipment
    @equipment_supply.destroy!

    respond_to do |format|
      format.html { redirect_to @location_equipment, notice: "El insumo ha sido eliminado del equipo.", status: :see_other }
      format.turbo_stream { render_supplies_list "El insumo ha sido eliminado del equipo." }
    end
  end

  private

  def set_equipment_supply
    @equipment_supply = authorize EquipmentSupply.find(params.expect(:id))
  end

  def equipment_supply_params
    params.require(:equipment_supply).permit(:location_equipment_id, :supply_id, :quantity)
  end

  def location_equipment_from_params
    location_equipment_id = params.expect(equipment_supply: [:location_equipment_id])[:location_equipment_id]
    LocationEquipment.visible.find(location_equipment_id)
  end

  def render_supplies_list(notice)
    @location_equipment = @equipment_supply.location_equipment
    flash.now[:notice] = notice
    render :refresh_list
  end
end
