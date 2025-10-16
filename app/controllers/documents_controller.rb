class DocumentsController < ApplicationController
  before_action :document, only: %i[show edit]
  before_action :documentable, only: %i[show edit update]
  before_action :documents, only: %i[update destroy] # to refresh the list after update or destroy

  def index
    redirect_to documentable
  end

  def show
  end

  def new
    @document = authorize documentable.documents.build
  end

  def create
    @document = authorize documentable.documents.build(document_params)

    if @document.save
      respond_to do |format|
        format.html { redirect_to polymorphic_path([documentable]), notice: "El documento se creó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El documento se creó correctamente." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if document.update(document_params)
      respond_to do |format|
        format.html { redirect_to polymorphic_path([documentable]), notice: "El documento se edito correctamente." }
        format.turbo_stream { flash.now[:notice] = "El documento se edito correctamente." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    flash.now[:notice] = "El documento ha sido eliminada." if document.destroy
    respond_to do |format|
      format.html { redirect_to polymorphic_path([documentable]), notice: "El documento ha sido eliminada." }
      format.turbo_stream
    end
  end

  private

  def documentable
    @documentable ||= if params[:id]
      authorize document.documentable
    else
      authorize documentable_type.constantize.find(documentable_id)
    end
  end

  def document
    @document ||= authorize Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:description, :file)
  end

  def documentable_type
    params[:document][:documentable_type]
  end

  def documentable_id
    params[:document][:documentable_id]
  end

  def documents
    @documents ||= documentable.documents.order(created_at: :desc)
  end
end
