class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @clients = Client.all
  end

  def show
  end

  def new
    @client = Client.new
  end

  def edit
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      respond_to do |format|
        format.html { redirect_to clients_path, notice: "El cliente fue creado con éxito." }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @client.update(client_params)
      redirect_to client_url(@client), notice: "El cliente ha sido actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy!

    redirect_to clients_url, notice: "El cliente ha sido eliminado"
  end

  private

  def set_client
    @client = Client.includes(:locations).find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :avatar)
  end
end
