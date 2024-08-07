class Client < ApplicationRecord
  has_one_attached :avatar
  has_many :locations, dependent: :destroy
  has_many :users, dependent: :destroy

  validates :name, presence: true
end
