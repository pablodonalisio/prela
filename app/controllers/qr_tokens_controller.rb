class QrTokensController < ApplicationController
  def scan
    qr_token = QrToken.kept.find_by!(token: params[:token])
    record = qr_token.scannable
    raise ActiveRecord::RecordNotFound if record.blank? || (record.respond_to?(:kept?) && !record.kept?)

    authorize record, :show?
    redirect_to record.qr_destination_path
  end
end
