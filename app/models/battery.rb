class Battery < ApplicationRecord
  has_one_attached :avatar

  validates :model, :voltage, :amps, presence: true

  alias_attribute :name, :model
end
