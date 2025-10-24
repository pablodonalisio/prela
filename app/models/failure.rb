class Failure < ApplicationRecord
  belongs_to :location_equipment

  validates :description, :date, presence: true
end
