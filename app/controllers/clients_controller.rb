class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @clients = Client.all
  end

  def show
    @location_equipments = LocationEquipment.where(location: @client.locations)
  end

  def new
    @client = Client.new
  end

  def edit
  end

  def create
    @client = Client.new(client_params)

    respond_to do |format|
      if @client.save
        format.html { redirect_to clients_path, notice: "El cliente fue creado con éxito." }
        format.turbo_stream { flash.now[:notice] = "El cliente fue creado con éxito" }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to client_url(@client), notice: "El cliente ha sido actualizado." }
        format.turbo_stream { flash.now[:notice] = "El cliente ha sido actualizado" }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @client.destroy!

    respond_to do |format|
      format.html { redirect_to clients_url, notice: "El cliente ha sido eliminado" }
      format.turbo_stream { flash.now[:notice] = "El cliente ha sido eliminado" }
    end
  end

  private

  def set_client
    @client = Client.includes(locations: :location_equipments).find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :avatar)
  end
end
