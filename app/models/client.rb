class Client < ApplicationRecord
  has_one_attached :avatar
  has_many :locations

  validates :name, presence: true
end
