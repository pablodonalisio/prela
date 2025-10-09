class Equipment < ApplicationRecord
  has_one_attached :avatar
  has_many :location_equipments, dependent: :destroy
  has_many :equipment_supplies, dependent: :destroy, as: :equipmentable
  has_one :equipment_battery, dependent: :destroy, as: :equipmentable, class_name: "EquipmentSupply"
  has_one :battery, through: :equipment_battery, source: :suppliable, source_type: "Battery"

  enum :kind, {ups: 0, power_unit: 1, electrical_panel: 2}

  validates :kind, :model, presence: true

  def full_name
    return "#{brand} - #{model}" if brand.present?

    model
  end
end
