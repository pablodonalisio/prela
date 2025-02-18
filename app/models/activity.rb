class Activity < ApplicationRecord
  SERVICE = "Service general"
  BATTERY_CHANGE = "Cambio batería"
  BELT_CHANGE = "Cambio correas"
  OTHER = "Otro"
  KINDS = [
    SERVICE,
    BATTERY_CHANGE,
    BELT_CHANGE,
    OTHER
  ]

  belongs_to :location_equipment
  has_one_attached :document

  validates :description, :date, presence: true
end
