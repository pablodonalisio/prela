class EquipmentSupply < ApplicationRecord
  belongs_to :location_equipment
  belongs_to :supply

  validates :quantity, numericality: {only_integer: true, greater_than: 0}
  validates :supply_id, uniqueness: {scope: :location_equipment_id}
end
