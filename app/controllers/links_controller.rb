
class LinksController < ApplicationController
        before_action :set_link, only: %i[edit update destroy]
      
        def index
          @links = Link.all
        end
      
        def new
          @link = Link.new
        end
        
        def create
          @link = Link.new(link_params)
          if @link.save
            redirect_to root_path, notice: "Enlace creado con éxito."
          else
            render :new, status: :unprocessable_entity
          end
        end
        
      
        def edit
        end
      
        def update
          if @link.update(link_params)
            redirect_to root_path, notice: "Enlace actualizado con éxito."
          else
            redirect_to root_path, alert: "Error al actualizar el enlace."
          end
        end
      
        def destroy
          @link.destroy
          redirect_to root_path, notice: "Enlace eliminado con éxito."
        end
      
        private
      
        def set_link
          @link = Link.find(params[:id])
        end
      
        def link_params
          params.require(:link).permit(:title, :url)
        end
    end
      

