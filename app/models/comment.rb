class Comment < ApplicationRecord
  belongs_to :location_equipment

  validates :description, presence: true
end
