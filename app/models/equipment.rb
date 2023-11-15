class Equipment < ApplicationRecord
  has_many :location_equipments, dependent: :destroy
  has_many :equipment_supplies, dependent: :destroy, as: :equipmentable

  validates :kind, :brand, :model, presence: true

  def full_name
    "#{brand} - #{model}"
  end
end
