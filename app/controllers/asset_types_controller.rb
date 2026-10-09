class AssetTypesController < ApplicationController
  before_action :set_asset_type, only: [:update, :destroy]
  before_action :set_equipment_kind_filter, if: -> { request.format.turbo_stream? }

  def create
    @asset_type = authorize AssetType.new(asset_type_params)
    @selected_id = params[:selected_id].presence
    @name_value = @asset_type.name
    @adding = false
    @editing_id = nil
    @error = nil

    respond_to do |format|
      if @asset_type.save
        @selected_id = @asset_type.id
        notice = "El tipo de activo se creó correctamente."
        format.html { redirect_to equipment_kinds_path, notice: notice }
        format.turbo_stream { flash.now[:notice] = notice }
      else
        @adding = true
        @error = @asset_type.errors.full_messages.to_sentence
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
      if @asset_type.update(asset_type_params)
        notice = "El tipo de activo se actualizó correctamente."
        format.html { redirect_to equipment_kinds_path, notice: notice, status: :see_other }
        format.turbo_stream { flash.now[:notice] = notice }
      else
        @editing_id = @asset_type.id
        @name_value = asset_type_params[:name]
        @error = @asset_type.errors.full_messages.to_sentence
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
      if @asset_type.discard
        if @selected_id.to_s == @asset_type.id.to_s
          @selected_id = AssetType.visible.find_by(system_key: AssetType::SYSTEM_UPS_KEY)&.id
        end
        notice = "El tipo de activo se eliminó."
        format.html { redirect_to equipment_kinds_path, notice: notice, status: :see_other }
        format.turbo_stream { flash.now[:notice] = notice }
      else
        alert = @asset_type.errors.full_messages.to_sentence
        @alert_message = alert
        format.html { redirect_to equipment_kinds_path, alert: alert, status: :see_other }
        format.turbo_stream { render :destroy, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_asset_type
    @asset_type = authorize AssetType.visible.find(params.expect(:id))
  end

  def asset_type_params
    params.require(:asset_type).permit(:name)
  end

  def set_equipment_kind_filter
    requested_ids = params.key?(:asset_type_ids) ? Array(params[:asset_type_ids]).compact_blank : referer_asset_type_ids
    @asset_type_ids = AssetType.visible.where(id: requested_ids).pluck(:id).map(&:to_s)
    @equipment_kinds = policy_scope(EquipmentKind.filter(asset_type_ids: @asset_type_ids))
      .includes(:service_kinds, :asset_type)
  end

  def referer_asset_type_ids
    query = URI.parse(request.referer.to_s).query
    Array(Rack::Utils.parse_nested_query(query.to_s)["asset_type_ids"]).compact_blank
  rescue URI::InvalidURIError
    []
  end
end
