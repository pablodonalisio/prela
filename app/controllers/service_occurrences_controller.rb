class ServiceOccurrencesController < ApplicationController
  before_action :set_location_equipment
  before_action :set_service_occurrence

  def edit
    authorize @service_occurrence
  end

  def update
    authorize @service_occurrence

    if @service_occurrence.update(update_params)
      respond_to do |format|
        format.html { redirect_to @location_equipment, notice: "La fecha de servicio se actualizó correctamente." }
        format.turbo_stream { flash.now[:notice] = "La fecha de servicio se actualizó correctamente." }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def complete
    authorize @service_occurrence, :complete?

    if request.get?
      render :complete
    else
      @service_occurrence.complete!(
        completed_on: complete_params[:completed_on],
        document: complete_params[:document]
      )
      respond_to do |format|
        format.html { redirect_to @location_equipment, notice: "El servicio se registró correctamente." }
        format.turbo_stream { flash.now[:notice] = "El servicio se registró correctamente." }
      end
    end
  rescue ActiveRecord::RecordInvalid, ArgumentError
    render :complete, status: :unprocessable_entity
  end

  private

  def set_location_equipment
    @location_equipment = LocationEquipment.find(params[:location_equipment_id])
  end

  def set_service_occurrence
    @service_occurrence = @location_equipment.service_occurrences.find(params[:id])
  end

  def update_params
    params.require(:service_occurrence).permit(:due_on)
  end

  def complete_params
    params.fetch(:service_occurrence, {}).permit(:completed_on, :document)
  end
end
