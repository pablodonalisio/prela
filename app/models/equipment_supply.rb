class EquipmentSupply < ApplicationRecord
  belongs_to :equipmentable, polymorphic: true
  belongs_to :suppliable, polymorphic: true
end
