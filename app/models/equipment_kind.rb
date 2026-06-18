class EquipmentKind < ApplicationRecord
  has_many :equipments, dependent: :destroy

  before_validation :set_normalized_name

  validates :name, presence: true
  validates :legacy_kind, inclusion: {in: Equipment::LEGACY_KINDS}, allow_nil: true
  validates :legacy_kind, uniqueness: true, allow_nil: true

  validate :generic_fields_must_be_present
  validate :validate_generic_field_definitions
  validate :validate_specific_field_definitions
  validate :name_must_be_unique

  FIELD_TYPES = %w[string integer float date boolean].freeze
  FIELD_SETS = %w[generic_fields specific_fields].freeze

  def self.generate_field_key
    Time.now.to_i
  end

  def self.normalize_name(value)
    ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
  end

  def field_definitions_for(field_set)
    public_send(field_set) || {}
  end

  private

  def set_normalized_name
    self.normalized_name = self.class.normalize_name(name)
  end

  def name_must_be_unique
    return if normalized_name.blank?

    scope = self.class.where(normalized_name: normalized_name)
    scope = scope.where.not(id: id) if persisted?

    errors.add(:name, :taken) if scope.exists?
  end

  def generic_fields_must_be_present
    return if generic_fields.is_a?(Hash) && generic_fields.any?

    errors.add(:generic_fields, "debe tener al menos un campo definido.")
  end

  def validate_generic_field_definitions
    validate_field_definitions(:generic_fields)
  end

  def validate_specific_field_definitions
    validate_field_definitions(:specific_fields)
  end

  def validate_field_definitions(attribute)
    definitions = public_send(attribute)
    return if definitions.nil?

    definitions.each do |_key, value|
      if value["name"].blank? || value["type"].blank?
        errors.add(attribute, "Los campos deben tener un nombre y un tipo.")
        break
      elsif !FIELD_TYPES.include?(value["type"])
        errors.add(attribute, "El tipo de campo #{value["type"]} no es válido.")
        break
      end
    end
  end
end
