class QrToken < ApplicationRecord
  include Discard::Model

  belongs_to :scannable, polymorphic: true

  has_secure_token
end
