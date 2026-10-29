class ReportTemplatesController < ApplicationController
  before_action :set_report_template, only: %i[edit update destroy]
  before_action :set_table_dropdowns, only: %i[new create edit update]

  def index
    @tab = params[:tab].to_s == "valores" ? "valores" : "lista"
    if @tab == "valores"
      @table_dropdowns = policy_scope(TableDropdown).includes(:table_dropdown_values).order(:name)
    else
      @report_templates = policy_scope(ReportTemplate).includes(:sections)
    end
  end

  def new
    @report_template = authorize ReportTemplate.new
  end

  def edit
  end

  def create
    @report_template = authorize ReportTemplate.new(report_template_params)

    if @report_template.save
      redirect_to report_templates_path, notice: "La plantilla de informe se creó correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @report_template.update(report_template_params)
      redirect_to report_templates_path, notice: "La plantilla de informe se actualizó correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @report_template.destroy!

    respond_to do |format|
      format.html { redirect_to report_templates_path, notice: "La plantilla de informe fue eliminada.", status: :see_other }
      format.turbo_stream { flash.now[:notice] = "La plantilla de informe fue eliminada." }
    end
  end

  private

  def set_report_template
    @report_template = authorize ReportTemplate.find(params.expect(:id))
  end

  def set_table_dropdowns
    @table_dropdowns = policy_scope(TableDropdown).includes(:table_dropdown_values).order(:name).to_a
  end

  def report_template_params
    params.require(:report_template).permit(
      :name,
      sections_attributes: [
        :id, :title, :position, :kind, :_destroy,
        text_section_attributes: %i[id _destroy],
        image_section_attributes: %i[id _destroy],
        list_section_attributes: [
          :id, :_destroy,
          {list_items_attributes: %i[id name position _destroy]}
        ],
        table_section_attributes: [
          :id, :row_count, :column_count, :_destroy,
          table_cells_attributes: [
            :id, :row_index, :column_index, :value_type, :value, :for_metrics, :fixed, :choice, :table_dropdown_id, :_destroy,
            {table_cell_options_attributes: %i[id value label _destroy]}
          ],
          table_labels_attributes: %i[id axis position label _destroy]
        ]
      ]
    )
  end
end
