class ReportTemplate < ApplicationRecord
  has_and_belongs_to_many :location_equipments
  has_many :reports, dependent: :nullify
  has_many :sections, -> { order(:position) }, as: :sectionable, dependent: :destroy, inverse_of: :sectionable, autosave: true

  accepts_nested_attributes_for :sections, allow_destroy: true

  before_validation :set_normalized_name, :normalize_section_positions

  validates :name, presence: true
  validate :name_must_be_unique

  def location_equipments_count
    location_equipments.merge(LocationEquipment.visible).size
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

  def normalize_section_positions
    sections.reject(&:marked_for_destruction?).sort_by.with_index { |section, index|
      [section.position.to_i, index]
    }.each_with_index do |section, index|
      section.position = index
    end
  end

  class << self
    def normalize_name(value)
      ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
    end
  end
end
