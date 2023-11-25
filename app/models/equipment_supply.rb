class EquipmentSupply < ApplicationRecord
  belongs_to :equipmentable, polymorphic: true
  belongs_to :suppliable, polymorphic: true

  delegate :avatar, :model, :voltage, :amps, to: :suppliable

  scope :batteries, -> { where(suppliable_type: "Battery") }
end
