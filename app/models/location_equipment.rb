class LocationEquipment < ApplicationRecord
  include Filterable

  belongs_to :location
  belongs_to :equipment
  has_many :equipment_supplies, dependent: :destroy
  has_one :equipment_battery, dependent: :destroy, as: :equipmentable, class_name: "EquipmentSupply"
  has_one :battery, through: :equipment_battery, source: :suppliable, source_type: "Battery"

  scope :by_client_ids, ->(client_id) { where(location: {client_id:}) }
  scope :by_location_ids, ->(location_id) { where(location_id:) }

  delegate :avatar, :model, to: :equipment
  delegate :client, to: :location
end
