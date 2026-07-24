class EquipmentKind < ApplicationRecord
  include FieldDefinitionsValidatable

  has_many :equipments, dependent: :destroy

  before_validation :set_normalized_name

  validates :name, presence: true
  validates :legacy_kind, inclusion: {in: Equipment::LEGACY_KINDS}, allow_nil: true
  validates :legacy_kind, uniqueness: true, allow_nil: true

  validate :generic_fields_must_be_present
  validate :validate_generic_field_definitions
  validate :validate_specific_field_definitions
  validate :name_must_be_unique

  after_update :sync_related_field_values, if: :field_definitions_changed?

  FIELD_TYPES = FieldDefinitionsValidatable::FIELD_TYPES
  FIELD_SETS = %w[generic_fields specific_fields].freeze

  def field_definitions_for(field_set)
    public_send(field_set) || {}
  end

  def equipments_count
    equipments.size
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

  def field_definitions_changed?
    saved_change_to_generic_fields? || saved_change_to_specific_fields?
  end

  def sync_related_field_values
    EquipmentKind::SyncFieldValues.call(self)
  end
end
