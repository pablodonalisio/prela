class LocationEquipment < ApplicationRecord
  belongs_to :location
  belongs_to :equipment
end
