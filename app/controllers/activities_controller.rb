class ActivitiesController < ApplicationController
  before_action :set_activities, only: %i[index destroy update]

  def index
    @activities = authorize location_equipment.activities.order(date: :desc)
  end

  def show
    @activity = authorize Activity.find(params[:id])
  end

  def new
    @activity = authorize location_equipment.activities.build
  end

  def create
    @activity = authorize location_equipment.activities.build(activity_params)

    if @activity.save
      respond_to do |format|
        format.html { redirect_to location_equipment_activities_path(location_equipment), notice: "La actividad se creó correctamente." }
        format.turbo_stream { flash.now[:notice] = "La actividad se creó correctamente." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @activity = authorize activity
  end

  def update
    @activity = authorize activity

    if @activity.update(activity_params)
      respond_to do |format|
        format.html { redirect_to location_equipment_activities_path(location_equipment), notice: "La actividad se edito correctamente." }
        format.turbo_stream { flash.now[:notice] = "La actividad se edito correctamente." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    flash.now[:notice] = "La actividad ha sido eliminada." if activity.destroy
  end

  private

  def location_equipment
    @location_equipment ||= LocationEquipment.find(params[:location_equipment_id])
  end

  def activity
    @activity ||= authorize location_equipment.activities.find(params[:id])
  end

  def activity_params
    params.require(:activity).permit(:description, :date, :document, :kind)
  end

  def set_activities
    @activities = location_equipment.activities.order(date: :desc)
  end
end
