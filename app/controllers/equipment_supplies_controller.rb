class EquipmentSuppliesController < ApplicationController
  def new
    @equipment_supply = EquipmentSupply.new(equipment_supply_params)
  end

  def create
    @equipment_supply = EquipmentSupply.new(equipment_supply_params)

    if @equipment_supply.save
      respond_to do |format|
        format.html { redirect_to url_for(@equipment_supply.equipmentable), notice: "Se ha agregado el insumo al equipo." }
        format.turbo_stream {}
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def equipment_supply_params
    params.require(:equipment_supply).permit(:equipmentable_id, :equipmentable_type, :suppliable_id,
      :suppliable_type, :quantity)
  end
end
