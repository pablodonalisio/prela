class Report < ApplicationRecord
  belongs_to :location_equipment

  has_one_attached :pdf
end
