class Location < ApplicationRecord
  belongs_to :client
  has_many :location_equipments, dependent: :destroy

  validates :name, presence: true
end
