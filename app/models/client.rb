class Client < ApplicationRecord
  has_one_attached :avatar
  has_many :locations, dependent: :destroy

  validates :name, presence: true
end
