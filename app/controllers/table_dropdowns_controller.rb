class TableDropdownsController < ApplicationController
  before_action :set_table_dropdown, only: %i[edit update destroy]

  def index
    authorize TableDropdown
    redirect_to report_templates_path(tab: "valores")
  end

  def new
    @table_dropdown = authorize TableDropdown.new
    @table_dropdown.table_dropdown_values.build
  end

  def edit
  end

  def create
    @table_dropdown = authorize TableDropdown.new(table_dropdown_params)

    respond_to do |format|
      if @table_dropdown.save
        format.html { redirect_to report_templates_path(tab: "valores"), notice: "El valor desplegable se creó correctamente." }
        format.turbo_stream { flash.now[:notice] = "El valor desplegable se creó correctamente." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @table_dropdown.update(table_dropdown_params)
        format.html { redirect_to report_templates_path(tab: "valores"), notice: "El valor desplegable se actualizó correctamente.", status: :see_other }
        format.turbo_stream { flash.now[:notice] = "El valor desplegable se actualizó correctamente." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    removed = @table_dropdown.discard
    message = if removed
      "El valor desplegable fue eliminado."
    else
      @table_dropdown.errors.full_messages.to_sentence.presence || "No se puede eliminar porque hay celdas que lo usan."
    end

    respond_to do |format|
      if removed
        format.html { redirect_to report_templates_path(tab: "valores"), notice: message, status: :see_other }
        format.turbo_stream { flash.now[:notice] = message }
      else
        format.html { redirect_to report_templates_path(tab: "valores"), alert: message, status: :see_other }
        format.turbo_stream { flash.now[:alert] = message }
      end
    end
  end

  private

  def set_table_dropdown
    @table_dropdown = authorize TableDropdown.visible.includes(:table_dropdown_values).find(params.expect(:id))
  end

  def table_dropdown_params
    params.require(:table_dropdown).permit(
      :name,
      table_dropdown_values_attributes: %i[id label position _destroy]
    )
  end
end
