class BatteriesController < ApplicationController
  def new
    @battery = Battery.new
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

  private

  def battery_params
    params.require(:battery).permit(:model, :voltage, :amps)
  end
end
