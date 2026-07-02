class ReportTemplate < ApplicationRecord
  include FieldDefinitionsValidatable

  FIELD_TYPES = FieldDefinitionsValidatable::FIELD_TYPES
  SECTIONS = %w[
    equipment_specifications
    location_specifications
    measurements
    room_specifications
  ].freeze

  has_and_belongs_to_many :location_equipments
  has_many :reports, dependent: :restrict_with_error

  before_validation :set_normalized_name

  validates :name, presence: true
  validate :name_must_be_unique
  validate :validate_section_field_definitions

  def active_sections
    self.class::SECTIONS.filter { |section| public_send(section).present? }
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

  def validate_section_field_definitions
    SECTIONS.each do |section|
      validate_field_definitions(section)
    end
  end
end
