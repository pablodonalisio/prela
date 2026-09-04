class ServiceOccurrencesController < ApplicationController
  before_action :set_location_equipment
  before_action :set_service_occurrence

  def edit
    authorize @service_occurrence
    @intent = intent
  end

  def update
    authorize @service_occurrence
    @intent = intent

    if ServiceOccurrences::Update.call(@service_occurrence, update_params)
      respond_to do |format|
        format.html { redirect_to @location_equipment, notice: update_notice }
        format.turbo_stream { flash.now[:notice] = update_notice }
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
    elsif ServiceOccurrences::Update.call(@service_occurrence, complete_params)
      respond_to do |format|
        format.html { redirect_to @location_equipment, notice: "El servicio se registró correctamente." }
        format.turbo_stream { flash.now[:notice] = "El servicio se registró correctamente." }
      end
    else
      render :complete, status: :unprocessable_entity
    end
  end

  private

  def set_location_equipment
    @location_equipment = LocationEquipment.find(params[:location_equipment_id])
  end

  def set_service_occurrence
    @service_occurrence = @location_equipment.service_occurrences.find(params[:id])
  end

  def intent
    params[:intent].presence_in(%w[due_on suspend schedule revert completed notes]) || "due_on"
  end

  def update_params
    case intent
    when "completed"
      params.require(:service_occurrence).permit(:completed_on, :notes, :document)
    when "notes"
      params.require(:service_occurrence).permit(:notes)
    else
      params.require(:service_occurrence).permit(:status, :due_on, :planned_on, :notes)
    end
  end

  def complete_params
    params.fetch(:service_occurrence, {}).permit(:completed_on, :document).merge(status: :completed)
  end

  def update_notice
    case @intent
    when "completed" then "El servicio se actualizó correctamente."
    when "notes" then "Las notas se actualizaron correctamente."
    else
      case @service_occurrence.status
      when "suspended" then "El servicio quedó suspendido."
      when "scheduled" then "El servicio se programó correctamente."
      when "pending" then (@intent == "revert") ? "El servicio volvió a pendiente." : "La fecha de servicio se actualizó correctamente."
      else "El servicio se actualizó correctamente."
      end
    end
  end
end
