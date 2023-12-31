class Battery < ApplicationRecord
  has_one_attached :avatar
  has_many :equipment_supplies, as: :suppliable, dependent: :destroy

  validates :model, :voltage, :amps, presence: true
end
