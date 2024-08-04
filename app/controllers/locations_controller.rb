class LocationsController < ApplicationController
  before_action :set_location, only: [:edit, :update, :destroy]

  def new
    @location = authorize client.locations.build
  end

  def edit
  end

  def create
    @location = authorize client.locations.build(location_params)

    if @location.save
      respond_to do |format|
        format.html { redirect_to client_path(client), notice: "Se ha creado la sede." }
        format.turbo_stream {}
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @location.update(location_params)
      respond_to do |format|
        format.html { redirect_to client_path(client), notice: "Se ha actualizado la sede." }
        format.turbo_stream {}
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy

    respond_to do |format|
      format.html { redirect_to client_path(client), notice: "La sede ha sido eliminada." }
      format.turbo_stream {}
    end
  end

  private

  def location_params
    params.require(:location).permit(:name, :client_id)
  end

  def client
    @client ||= Client.find(params[:client_id])
  end

  def set_location
    @location = authorize client.locations.find(params[:id])
  end
end
