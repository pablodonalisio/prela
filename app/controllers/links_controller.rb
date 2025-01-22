
class LinksController < ApplicationController
  before_action :set_link, only: %i[edit update destroy]
  before_action :set_links, only: %i[destroy update]

  def new
    @link = Link.new
  end
  
  def create
    @link = Link.new(link_params)
    if @link.save
      respond_to do |format|
        format.html { redirect_to home_path, notice: "El enlace se creo correctamente." }
        format.turbo_stream { flash.now[:notice] = "El enlace se creo correctamente." }
      end
    else
      render :new, status: :unprocessable_entity, alert: @link.errors.full_messages.join
    end
  end
  

  def edit
  end

  def update
    if @link.update(link_params)
      respond_to do |format|
        format.html { redirect_to home_path, notice: "El enlace se actualizó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El enlace se actualizó correctamente." }
      end
    else
      render :update, status: :unprocessable_entity, alert: @link.errors.full_messages.join
    end
  end

  def destroy
    @link.destroy
    respond_to do |format|
      format.html { redirect_to home_path, notice: "Enlace eliminado con éxito." }
      format.turbo_stream { flash.now[:notice] = "Enlace eliminado con éxito." }
    end
  end

  private

  def set_link
    @link = Link.find(params[:id])
  end

  def set_links
    @links = Link.all
  end

  def link_params
    params.require(:link).permit(:title, :url)
  end
end
      


