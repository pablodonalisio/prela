class SuppliesController < ApplicationController
  before_action :set_supply, only: %i[edit update destroy]

  def index
    load_supplies
  end

  def new
    @supply = authorize Supply.new
  end

  def edit
  end

  def create
    @supply = authorize Supply.new(supply_params)

    respond_to do |format|
      if @supply.save
        format.html { redirect_to supplies_path, notice: "El insumo se creó correctamente." }
        format.turbo_stream { render_supplies_list "El insumo se creó correctamente." }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @supply.update(supply_params)
        format.html { redirect_to supplies_path, notice: "El insumo se actualizó correctamente.", status: :see_other }
        format.turbo_stream { render_supplies_list "El insumo se actualizó correctamente." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @supply.discard!

    respond_to do |format|
      format.html { redirect_to supplies_path, notice: "El insumo se eliminó.", status: :see_other }
      format.turbo_stream { render_supplies_list "El insumo se eliminó." }
    end
  end

  private

  def set_supply
    @supply = authorize Supply.visible.find(params.expect(:id))
  end

  def supply_params
    params.require(:supply).permit(:supply_kind_id, :name, :description, :reference_url, :avatar, replacement_ids: [])
  end

  def render_supplies_list(notice)
    load_supplies
    flash.now[:notice] = notice
    render :refresh_list
  end

  def load_supplies
    context = list_context
    @supply_kind_ids = Array(context[:supply_kind_ids]).compact_blank
    @name = context[:name].to_s.strip.presence
    @pagy, @supplies = paginate_supplies(supplies_scope, context[:page])
  end

  def supplies_scope
    policy_scope(Supply.filter(supply_kind_ids: @supply_kind_ids, name: @name))
      .includes(:supply_kind, replacement_links: :replacement, replaced_by_links: :supply)
      .with_attached_avatar
      .order(:name)
  end

  def list_context
    source = request.get? ? params : referer_query_params
    {page: source[:page], supply_kind_ids: source[:supply_kind_ids], name: source[:name]}
  end

  def referer_query_params
    query = URI.parse(request.referer.to_s).query
    ActionController::Parameters.new(Rack::Utils.parse_nested_query(query.to_s)).permit(:page, :name, supply_kind_ids: [])
  rescue URI::InvalidURIError
    ActionController::Parameters.new
  end

  def paginate_supplies(scope, page)
    pagy_vars = {request_path: supplies_path}
    pagy_vars[:page] = page if page.present?
    filter_params = {}
    filter_params[:supply_kind_ids] = @supply_kind_ids if @supply_kind_ids.present?
    filter_params[:name] = @name if @name.present?
    pagy_vars[:params] = filter_params if filter_params.present?
    pagy(scope, **pagy_vars)
  rescue Pagy::OverflowError => error
    pagy(scope, **pagy_vars, page: error.pagy.last)
  end
end
