class LocationEquipment < ApplicationRecord
  include Filterable

  belongs_to :location
  belongs_to :equipment

  scope :by_client_ids, ->(client_id) { where(location: {client_id:}) }
end
