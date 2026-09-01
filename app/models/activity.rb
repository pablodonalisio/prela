class Activity < ApplicationRecord
  belongs_to :location_equipment
  has_one_attached :document

  validates :description, :date, presence: true
end
