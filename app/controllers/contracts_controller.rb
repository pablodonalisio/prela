class ContractsController < ApplicationController
  before_action :set_contract, only: [:edit, :update, :destroy]

  def index
    authorize client, :contracts?
    @panel = :contracts
    render "clients/show"
  end

  def new
    @contract = authorize client.contracts.build
  end

  def edit
  end

  def create
    @contract = authorize client.contracts.build(contract_params)

    if @contract.save
      respond_to do |format|
        format.html { redirect_to client_path(client), notice: "Se ha creado el contrato." }
        format.turbo_stream {}
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @contract.update(contract_params)
      respond_to do |format|
        format.html { redirect_to client_path(client), notice: "Se ha actualizado el contrato." }
        format.turbo_stream {}
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contract.discard!

    respond_to do |format|
      format.html { redirect_to client_path(client), notice: "El contrato ha sido eliminado." }
      format.turbo_stream {}
    end
  end

  private

  def contract_params
    params.require(:contract).permit(:name, :file, :starts_on, :ends_on)
  end

  def client
    @client ||= Client.visible.find(params[:client_id])
  end

  def set_contract
    @contract = authorize client.contracts.kept.find(params[:id])
  end
end
