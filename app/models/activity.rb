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
  has_one :service_date, dependent: :destroy

  validates :description, :date, :kind, presence: true
end
