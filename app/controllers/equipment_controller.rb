class EquipmentController < ApplicationController
  def new
    @equipment = Equipment.new
  end

  def index
    @equipment = Equipment.all
  end

  def edit
    equipment
  end

  def create
    @equipment = Equipment.new(equipment_params)

    respond_to do |format|
      if @equipment.save
        format.html { redirect_to equipment_index_path, notice: "El equipo ha sido creado con exito!" }
        format.turbo_stream { flash.now[:notice] = "El equipo ha sido creado con exito!" }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if equipment.update(equipment_params)
        format.html { redirect_to equipment_index_path, notice: "El equipo ha sido actualizado con exito!" }
        format.turbo_stream { flash.now[:notice] = "El equipo ha sido actualizado con exito!" }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    equipment.destroy!

    respond_to do |format|
      format.html { redirect_to equipment_index_path, notice: "El equipo ha sido eliminado" }
      format.turbo_stream { flash.now[:notice] = "El equipo ha sido eliminado" }
    end
  end

  private

  def equipment_params
    params.require(:equipment).permit(:kind, :brand, :model, :technical_model,
      :kva, :battery_qty, :battery_type, :battery_info, :manual, :details)
  end

  def equipment
    @equipment = Equipment.find(params[:id])
  end
end
