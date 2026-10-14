class QrTokensController < ApplicationController
  SCANNABLE_PARAMS = {
    "location_equipment_id" => LocationEquipment
  }.freeze

  def show
    @scannable = find_scannable
    authorize @scannable.qr_token || QrToken.new(scannable: @scannable)
    @qr_token = @scannable.ensure_qr_token!
    render layout: "label"
  end

  def scan
    qr_token = QrToken.kept.find_by!(token: params[:token])
    record = qr_token.scannable
    raise ActiveRecord::RecordNotFound if record.blank? || (record.respond_to?(:kept?) && !record.kept?)

    authorize record, :show?
    redirect_to record.qr_destination_path
  end

  private

  def find_scannable
    param_key, model = SCANNABLE_PARAMS.find { |key, _| params[key].present? }
    raise ActiveRecord::RecordNotFound if model.nil?

    scope = model.respond_to?(:visible) ? model.visible : model
    scope.find(params[param_key])
  end
end
