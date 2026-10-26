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
    @contract = authorize client.contracts.build(contract_attributes)
    attach_new_files

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
    @contract.assign_attributes(contract_attributes)
    attach_new_files
    @contract.removed_file_blob_ids = removed_file_ids

    if @contract.save
      purge_removed_files
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

  def contract_attributes
    params.require(:contract).permit(:name, :starts_on, :ends_on)
  end

  def new_files
    Array(params.dig(:contract, :files)).compact_blank
  end

  def removed_file_ids
    Array(params.dig(:contract, :removed_file_ids)).compact_blank
  end

  def attach_new_files
    return if new_files.empty?

    @contract.files.attach(new_files)
  end

  def purge_removed_files
    return if removed_file_ids.empty?

    @contract.files.where(blob_id: removed_file_ids).find_each(&:purge)
    @contract.files.reload
  end

  def client
    @client ||= Client.visible.find(params[:client_id])
  end

  def set_contract
    @contract = authorize client.contracts.kept.find(params[:id])
  end
end
