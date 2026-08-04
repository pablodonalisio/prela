class Location < ApplicationRecord
  include Discard::Model

  belongs_to :client
  has_many :location_equipments
  has_and_belongs_to_many :contacts

  validates :name, presence: true

  scope :visible, -> { kept.where(client_id: Client.kept.select(:id)) }
end
