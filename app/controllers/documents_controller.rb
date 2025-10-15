class DocumentsController < ApplicationController
  def index
    redirect_to documentable
  end

  def show
    @document = authorize Document.find(params[:id])
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
    @document = authorize document
  end

  def update
    @document = authorize document

    if @document.update(document_params)
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
    @documentable ||= authorize params[:documentable_type].constantize.find(params[:documentable_id])
  end

  def document
    @document ||= authorize documentable.documents.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:description, :file)
  end
end
