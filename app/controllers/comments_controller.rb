class CommentsController < ApplicationController
  before_action :comment, only: %i[edit]
  before_action :location_equipment, only: %i[edit update]
  before_action :comments, only: %i[update destroy]

  def index
    redirect_to location_equipment_path(location_equipment)
  end

  def new
    @comment = authorize location_equipment.comments.build
  end

  def create
    @comment = authorize location_equipment.comments.build(comment_params)

    if @comment.save
      respond_to do |format|
        format.html { redirect_to location_equipment_path(location_equipment), notice: "El comentario se creó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El comentario se creó correctamente." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if comment.update(comment_params)
      respond_to do |format|
        format.html { redirect_to location_equipment_path(location_equipment), notice: "El comentario se editó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El comentario se editó correctamente." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    flash.now[:notice] = "El comentario ha sido eliminado." if comment.destroy
    respond_to do |format|
      format.html { redirect_to location_equipment_path(location_equipment), notice: "El comentario ha sido eliminado." }
      format.turbo_stream
    end
  end

  private

  def comment
    @comment ||= authorize location_equipment.comments.find(params[:id])
  end

  def location_equipment
    @location_equipment ||= LocationEquipment.find(params[:location_equipment_id])
  end

  def comment_params
    params.require(:comment).permit(:description)
  end

  def comments
    @comments ||= location_equipment.comments.order(updated_at: :desc)
  end
end
