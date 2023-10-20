class Equipment < ApplicationRecord
  has_many :location_equipments, dependent: :destroy
  validates :kind, :brand, :model, presence: true
end
