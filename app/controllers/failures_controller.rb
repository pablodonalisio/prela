class FailuresController < ApplicationController
  before_action :failure, only: %i[edit]

  def index
    redirect_to location_equipment_path(location_equipment)
  end

  def new
    @failure = authorize location_equipment.failures.build
  end

  def create
    @failure = authorize location_equipment.failures.build(failure_params)

    if @failure.save
      respond_to do |format|
        format.html { redirect_to location_equipment_path(location_equipment), notice: "El fallo se creó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El fallo se creó correctamente." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if failure.update(failure_params)
      respond_to do |format|
        format.html { redirect_to location_equipment_path(location_equipment), notice: "El fallo se edito correctamente." }
        format.turbo_stream { flash.now[:notice] = "El fallo se edito correctamente." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    flash.now[:notice] = "El fallo ha sido eliminada." if failure.destroy
    respond_to do |format|
      format.html { redirect_to location_equipment_path(location_equipment), notice: "El fallo ha sido eliminada." }
      format.turbo_stream
    end
  end

  private

  def failure
    @failure ||= authorize location_equipment.failures.find(params[:id])
  end

  def location_equipment
    @location_equipment ||= LocationEquipment.find(params[:location_equipment_id])
  end

  def failure_params
    params.require(:failure).permit(:description, :date)
  end
end
