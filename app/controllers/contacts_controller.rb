class ContactsController < ApplicationController
  before_action :set_contact, only: [:edit, :update, :destroy]

  def new
    @contact = authorize client.contacts.build
  end

  def edit
  end

  def create
    @contact = authorize client.contacts.build(contact_params)

    if @contact.save
      respond_to do |format|
        format.html { redirect_to client_path(client), notice: "Se ha creado el contacto." }
        format.turbo_stream {}
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @contact.update(contact_params)
      respond_to do |format|
        format.html { redirect_to client_path(client), notice: "Se ha actualizado el contacto." }
        format.turbo_stream {}
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.discard!

    respond_to do |format|
      format.html { redirect_to client_path(client), notice: "El contacto ha sido eliminado." }
      format.turbo_stream {}
    end
  end

  private

  def contact_params
    params.require(:contact).permit(
      :name, :work_area, :job_position, :description, :email, :phone, :location_id, :reports_to_id
    )
  end

  def client
    @client ||= Client.visible.find(params[:client_id])
  end

  def set_contact
    @contact = authorize client.contacts.kept.find(params[:id])
  end
end
