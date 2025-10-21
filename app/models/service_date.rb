class ServiceDate < ApplicationRecord
  belongs_to :location_equipment
  belongs_to :activity, optional: true

  enum :kind, {service: 0, battery_change: 1, belt_change: 2, torque: 3, cleaning: 4, srt_900: 5, thermography: 6, electrical_approval: 7}

  validates :kind, :date, presence: true
end
