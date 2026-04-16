class EquipmentKind < ApplicationRecord
  has_many :equipments, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validates :fields, presence: true

  FIELD_TYPES = %w[string integer float date boolean].freeze
end
