class BatteriesController < ApplicationController
  before_action :set_battery, only: %i[show edit update destroy]

  def new
    @battery = Battery.new
  end

  def edit
  end

  def show
  end

  def create
    @battery = Battery.new(battery_params)

    respond_to do |format|
      if @battery.save
        format.html { redirect_to supplies_path }
        format.turbo_stream {}
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @battery.update(battery_params)
        format.html { redirect_to supplies_url }
        format.turbo_stream {}
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @battery.destroy!

    respond_to do |format|
      format.html { redirect_to supplies_url, notice: "La batería ha sido eliminada" }
      format.turbo_stream {}
    end
  end

  private

  def battery_params
    params.require(:battery).permit(:model, :voltage, :amps, :avatar)
  end

  def set_battery
    @battery = Battery.find(params[:id])
  end
end
