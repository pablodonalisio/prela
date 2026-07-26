class SignaturesController < ApplicationController
  before_action :set_signatures, only: %i[index destroy update]
  before_action :set_signature, only: %i[edit update destroy]

  def index
  end

  def new
    @signature = authorize Signature.new
  end

  def create
    @signature = authorize Signature.new(signature_params)

    if @signature.save
      respond_to do |format|
        format.html { redirect_to signatures_path, notice: "Firma creada exitosamente" }
        format.turbo_stream { flash.now[:notice] = "Firma creada exitosamente" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @signature.update(signature_params)
      respond_to do |format|
        format.html { redirect_to signatures_path, notice: "Firma actualizada exitosamente" }
        format.turbo_stream { flash.now[:notice] = "Firma actualizada exitosamente" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @signature.discard
      flash.now[:notice] = "La firma ha sido eliminada."
      @signatures = Signature.kept.order(created_at: :desc)
    end
  end

  private

  def signature_params
    params.require(:signature).permit(:name, :title, :image)
  end

  def set_signatures
    @signatures = authorize Signature.kept.order(created_at: :desc)
  end

  def set_signature
    @signature = authorize Signature.kept.find(params[:id])
  end
end
