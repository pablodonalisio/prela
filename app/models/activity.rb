class Activity < ApplicationRecord
  SERVICE = "Service general"
  BATTERY_CHANGE = "Cambio batería"
  BELT_CHANGE = "Cambio correas"
  TORQUE = "Torqueo"
  CLEANING = "Limpieza"
  SRT_900 = "SRT-900"
  THERMOGRAPHY = "Termografía"
  ELECTRICAL_APPROVAL = "Apto eléctrico"
  OTHER = "Otro"
  KINDS = {
    SERVICE => :service,
    BATTERY_CHANGE => :battery_change,
    BELT_CHANGE => :belt_change,
    TORQUE => :torque,
    CLEANING => :cleaning,
    SRT_900 => :srt_900,
    THERMOGRAPHY => :thermography,
    ELECTRICAL_APPROVAL => :electrical_approval,
    OTHER => :other
  }

  belongs_to :location_equipment
  has_one_attached :document

  validates :description, :date, presence: true
end
