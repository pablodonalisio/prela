class Equipment < ApplicationRecord
  validates :kind, :brand, :model, presence: true
end
