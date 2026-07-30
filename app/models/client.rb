class Client < ApplicationRecord
  include Discard::Model

  has_one_attached :avatar
  has_many :locations
  has_many :contacts
  has_many :users, dependent: :destroy

  validates :name, presence: true

  scope :visible, -> { kept }
end
