class Equipment < ApplicationRecord
  has_many :location_equipments, dependent: :destroy
  validates :kind, :brand, :model, presence: true

  def full_name
    "#{brand} - #{model}"
  end
end
