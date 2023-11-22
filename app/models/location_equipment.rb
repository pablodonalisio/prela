class LocationEquipment < ApplicationRecord
  include Filterable

  belongs_to :location
  belongs_to :equipment

  scope :by_client_ids, ->(client_id) { where(location: {client_id:}) }
  scope :by_location_ids, ->(location_id) { where(location_id:) }

  delegate :avatar, :model, to: :equipment
  delegate :client, to: :location
end
