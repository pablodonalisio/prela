class EquipmentKind < ApplicationRecord
  has_many :equipments, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validate :fields_names_must_be_present

  FIELD_TYPES = %w[string integer float date boolean].freeze

  def self.generate_field_key
    Time.now.to_i
  end

  private

  def fields_names_must_be_present
    return if fields.nil?

    fields.each do |key, value|
      if value["name"].blank? || value["type"].blank?
        errors.add(:fields, "Los campos deben tener un nombre y un tipo.")
        break
      elsif !FIELD_TYPES.include?(value["type"])
        errors.add(:fields, "El tipo de campo #{value["type"]} no es válido.")
        break
      end
    end
  end
end
