class ReportTemplatesController < ApplicationController
  before_action :set_report_template, only: %i[edit update destroy]

  def index
    @report_templates = policy_scope(ReportTemplate)
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
      render :new, status: :unprocessable_entity, formats: [:html]
    end
  end

  def update
    if @report_template.update(report_template_params)
      redirect_to report_templates_path, notice: "La plantilla de informe se actualizó correctamente.", status: :see_other
    else
      render :edit, status: :unprocessable_entity, formats: [:html]
    end
  end

  def destroy
    @report_template.destroy!

    respond_to do |format|
      format.html { redirect_to report_templates_path, notice: "La plantilla de informe fue eliminada.", status: :see_other }
      format.turbo_stream { flash.now[:notice] = "La plantilla de informe fue eliminada." }
    end
  end

  def add_field
    @section = section_param
    @field_key = ReportTemplate.generate_field_key

    respond_to do |format|
      format.turbo_stream
    end
  end

  def remove_field
    @field_key = params[:field_key]

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_report_template
    @report_template = authorize ReportTemplate.find(params.expect(:id))
  end

  def report_template_params
    permitted = params.require(:report_template).permit(
      :name,
      equipment_specifications: {},
      location_specifications: {},
      measurements: {},
      room_specifications: {},
      report_template_tasks_attributes: %i[id name position _destroy],
      layout: [:id, :type, :title]
    )

    ReportTemplate::SECTIONS.each do |section|
      permitted[section.to_sym] ||= {}
    end

    permitted
  end

  def section_param
    section = params.fetch(:section, ReportTemplate::SECTIONS.first)
    ReportTemplate::SECTIONS.include?(section) ? section : ReportTemplate::SECTIONS.first
  end
end
