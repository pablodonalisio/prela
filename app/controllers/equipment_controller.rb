class EquipmentController < ApplicationController
  before_action :set_equipment, except: %i[new index create]

  def new
    @equipment = authorize Equipment.new
  end

  def index
    @equipment = authorize Equipment.all
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
    @equipment.destroy!

    respond_to do |format|
      format.html { redirect_to equipment_index_path, notice: "El equipo ha sido eliminado" }
      format.turbo_stream {}
    end
  end

  private

  def equipment_params
    params.require(:equipment).permit(:avatar, :kind, :brand, :model, :technical_model,
      :kva, :manual, :details, :battery, :more_info, :motor_brand, :motor_model, :generator_brand,
      :generator_model, :kw)
  end

  def set_equipment
    @equipment = authorize Equipment.find(params[:id])
  end
end
