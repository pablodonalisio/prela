class Location < ApplicationRecord
  belongs_to :client, dependent: :destroy

  validates :name, presence: true
end
