module QrScannable
  extend ActiveSupport::Concern

  included do
    has_many :qr_tokens, as: :scannable
    has_one :qr_token, -> { kept }, as: :scannable, class_name: "QrToken"
  end

  def ensure_qr_token!
    qr_token || create_qr_token!
  end

  def regenerate_qr_token!
    transaction do
      qr_token&.discard!
      reload_qr_token
      create_qr_token!
    end
  end

  def qr_destination_path
    Rails.application.routes.url_helpers.polymorphic_path(self)
  end
end
