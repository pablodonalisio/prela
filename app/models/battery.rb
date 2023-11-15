class Battery < ApplicationRecord
  has_one_attached :avatar

  validates :model, presence: true
end
