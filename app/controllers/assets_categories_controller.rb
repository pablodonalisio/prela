class AssetsCategoriesController < ApplicationController
  before_action :set_assets_category, only: [:update, :destroy]
  before_action :set_equipment_kind_filter, if: -> { request.format.turbo_stream? }

  def create
    @assets_category = authorize AssetsCategory.new(assets_category_params)
    @selected_id = params[:selected_id].presence
    @name_value = @assets_category.name
    @adding = false
    @editing_id = nil
    @error = nil

    respond_to do |format|
      if @assets_category.save
        @selected_id = @assets_category.id
        notice = "La categoría se creó correctamente."
        format.html { redirect_to equipment_kinds_path, notice: notice }
        format.turbo_stream { flash.now[:notice] = notice }
      else
        @adding = true
        @error = @assets_category.errors.full_messages.to_sentence
        format.html { redirect_to equipment_kinds_path, alert: @error }
        format.turbo_stream { render :form_update, status: :unprocessable_entity }
      end
    end
  end

  def update
    @selected_id = params[:selected_id].presence
    @adding = false
    @editing_id = nil
    @name_value = nil
    @error = nil

    respond_to do |format|
      if @assets_category.update(assets_category_params)
        notice = "La categoría se actualizó correctamente."
        format.html { redirect_to equipment_kinds_path, notice: notice, status: :see_other }
        format.turbo_stream { flash.now[:notice] = notice }
      else
        @editing_id = @assets_category.id
        @name_value = assets_category_params[:name]
        @error = @assets_category.errors.full_messages.to_sentence
        format.html { redirect_to equipment_kinds_path, alert: @error, status: :see_other }
        format.turbo_stream { render :update, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @selected_id = params[:selected_id].presence
    @adding = false
    @editing_id = nil
    @error = nil
    @name_value = nil

    respond_to do |format|
      if @assets_category.discard
        @selected_id = nil if @selected_id.to_s == @assets_category.id.to_s
        notice = "La categoría se eliminó."
        format.html { redirect_to equipment_kinds_path, notice: notice, status: :see_other }
        format.turbo_stream { flash.now[:notice] = notice }
      else
        alert = @assets_category.errors.full_messages.to_sentence
        @alert_message = alert
        format.html { redirect_to equipment_kinds_path, alert: alert, status: :see_other }
        format.turbo_stream { render :destroy, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_assets_category
    @assets_category = authorize AssetsCategory.visible.find(params.expect(:id))
  end

  def assets_category_params
    params.require(:assets_category).permit(:name)
  end

  def set_equipment_kind_filter
    requested_ids = params.key?(:assets_category_ids) ? Array(params[:assets_category_ids]).compact_blank : referer_assets_category_ids
    @assets_category_ids = AssetsCategory.visible.where(id: requested_ids).pluck(:id).map(&:to_s)
    @equipment_kinds = policy_scope(EquipmentKind.filter(assets_category_ids: @assets_category_ids))
      .includes(:service_kinds, :assets_category)
  end

  def referer_assets_category_ids
    query = URI.parse(request.referer.to_s).query
    Array(Rack::Utils.parse_nested_query(query.to_s)["assets_category_ids"]).compact_blank
  rescue URI::InvalidURIError
    []
  end
end
