class EquipmentSuppliesController < ApplicationController
  before_action :set_equipment_supply, only: %i[edit update destroy]

  def new
    @equipment_supply = authorize EquipmentSupply.new(equipment_supply_params)
  end

  def edit
  end

  def create
    @equipment_supply = authorize EquipmentSupply.new(equipment_supply_params)

    if @equipment_supply.save
      respond_to do |format|
        format.html { redirect_to url_for(@equipment_supply.equipmentable), notice: "Se ha agregado el insumo al equipo." }
        format.turbo_stream {}
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @equipment_supply.update(equipment_supply_params)
      respond_to do |format|
        format.html { redirect_to url_for(@equipment_supply.equipmentable), notice: "Se ha agregado el insumo al equipo." }
        format.turbo_stream {}
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @equipment_supply.destroy

    respond_to do |format|
      format.html { redirect_to url_for(@equipment_supply.equipmentable), notice: "El insumo ha sido eliminado del equipo" }
      format.turbo_stream {}
    end
  end

  private

  def equipment_supply_params
    params.require(:equipment_supply).permit(:equipmentable_id, :equipmentable_type, :suppliable_id,
      :suppliable_type, :quantity)
  end

  def set_equipment_supply
    @equipment_supply = authorize EquipmentSupply.find(params[:id])
  end
end
