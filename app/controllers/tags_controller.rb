class TagsController < ApplicationController
  before_action :set_tag, only: %i[edit update destroy]

  def index
    @tags = policy_scope(Tag).order(:name)
  end

  def new
    @tag = authorize Tag.new
  end

  def edit
  end

  def create
    @tag = authorize Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to tags_path, notice: "La etiqueta se creo correctamente." }
        format.turbo_stream { flash.now[:notice] = "La etiqueta se creo correctamente." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to tags_path, notice: "La etiqueta se actualizo correctamente.", status: :see_other }
        format.turbo_stream { flash.now[:notice] = "La etiqueta se actualizo correctamente." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @tag.discard!

    respond_to do |format|
      format.html { redirect_to tags_path, notice: "La etiqueta a sido eliminada.", status: :see_other }
      format.turbo_stream { flash.now[:notice] = "La etiqueta a sido eliminada." }
    end
  end

  private

  def set_tag
    @tag = authorize Tag.visible.find(params.expect(:id))
  end

  def tag_params
    params.require(:tag).permit(:name, :color)
  end
end
