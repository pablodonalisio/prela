class TextSection < ApplicationRecord
  belongs_to :section

  before_validation :sanitize_body

  private

  def sanitize_body
    self.body = RichText::Sanitize.call(body).presence
  end
end
