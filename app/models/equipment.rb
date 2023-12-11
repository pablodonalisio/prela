class Equipment < ApplicationRecord
  has_one_attached :avatar
  has_many :location_equipments, dependent: :destroy
  has_many :equipment_supplies, dependent: :destroy, as: :equipmentable
  has_one :equipment_battery, dependent: :destroy, as: :equipmentable, class_name: "EquipmentSupply"
  has_one :battery, through: :equipment_battery, source: :suppliable, source_type: "Battery"

  validates :kind, :brand, :model, presence: true
  validates :kind, inclusion: {in: ["UPS"], message: "%{value} no es un tipo válido"}

  def full_name
    "#{brand} - #{model}"
  end
end
