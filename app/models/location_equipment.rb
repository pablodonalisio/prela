class LocationEquipment < ApplicationRecord
  include Filterable

  belongs_to :location
  belongs_to :equipment
  has_many :equipment_supplies, dependent: :destroy, as: :equipmentable
  has_one :equipment_battery, dependent: :destroy, as: :equipmentable, class_name: "EquipmentSupply"
  has_one :battery, through: :equipment_battery, source: :suppliable, source_type: "Battery"
  has_many :reports, dependent: :destroy
  has_many :activities, dependent: :destroy

  scope :by_client_ids, ->(client_id) { joins(:location).where(location: {client_id:}) }
  scope :by_location_ids, ->(location_id) { where(location_id:) }
  scope :by_status, ->(status) { where(status:) }
  scope :by_kind, ->(kind) { joins(:equipment).where(equipment: {kind:}) }
  scope :ups_with_overdue_maintenance, -> { by_kind(:ups).where("next_service < ? OR next_battery_change < ?", Date.current, Date.current) }
  scope :power_units_with_overdue_maintenance, -> { by_kind(:power_unit).where("next_service < ? OR next_battery_change < ?", Date.current, Date.current) }

  enum status: {active: 0, out_of_service: 1, prela_to_check: 2, prela_to_deliver: 3, prela_on_service: 4, inaccessible: 5}

  delegate :avatar, :model, to: :equipment
  delegate :client, to: :location
end
