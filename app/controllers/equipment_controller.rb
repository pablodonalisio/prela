class EquipmentController < ApplicationController
  before_action :set_equipment, except: %i[new index create field_inputs]

  def new
    @equipment = authorize Equipment.new
  end

  def index
    authorize Equipment
    @pagy, @equipment = pagy(Equipment.visible)
  end


  def show
  end

  def edit
  end

  def create
    @equipment = authorize Equipment.new(equipment_params)

    respond_to do |format|
      if @equipment.save
        format.html { redirect_to equipment_index_path, notice: "El equipo ha sido creado con exito!" }
        format.turbo_stream {}
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @equipment.update(equipment_params)
        format.html { redirect_to equipment_index_path, notice: "El equipo ha sido actualizado con exito!" }
        format.turbo_stream {}
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @equipment.discard!

    respond_to do |format|
      format.html { redirect_to equipment_index_path, notice: "El equipo ha sido eliminado" }
      format.turbo_stream {}
    end
  end

  def field_inputs
    @equipment_kind = EquipmentKind.visible.find_by(id: params[:equipment_kind_id])
    existing = Equipment.visible.find_by(id: params[:equipment_id])
    @field_values = existing&.field_values || {}
  end

  private

  def equipment_params
    params.require(:equipment).permit(:avatar, :equipment_kind_id, :name, :brand, :model, field_values: {})
  end

  def set_equipment
    @equipment = authorize Equipment.visible.find(params[:id])
  end
end

