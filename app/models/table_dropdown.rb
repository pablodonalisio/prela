class TableDropdown < ApplicationRecord
  include Discard::Model

  belongs_to :report, optional: true, inverse_of: :table_dropdowns
  has_many :table_dropdown_values, -> { order(:position) }, dependent: :destroy, inverse_of: :table_dropdown
  has_many :table_cells, dependent: :restrict_with_error

  accepts_nested_attributes_for :table_dropdown_values, allow_destroy: true, reject_if: :reject_blank_value

  before_validation :set_normalized_name, :normalize_value_positions, :assign_report_id
  before_discard :ensure_not_in_use

  validates :name, presence: true
  validate :name_must_be_unique
  validate :at_least_one_value

  scope :visible, -> { kept.where(report_id: nil) }

  def self.normalize_name(value)
    ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
  end

  private

  def reject_blank_value(attributes)
    attributes["label"].blank? && attributes["id"].blank?
  end

  def set_normalized_name
    self.normalized_name = self.class.normalize_name(name)
  end

  def normalize_value_positions
    table_dropdown_values.reject(&:marked_for_destruction?).each_with_index do |item, index|
      item.position = index
    end
  end

  def assign_report_id
    self.report_id ||= report.id if report&.persisted?
  end

  def name_must_be_unique
    return if normalized_name.blank?
    return if report_id.present? || report.present?

    scope = self.class.kept.where(report_id: nil, normalized_name: normalized_name)
    scope = scope.where.not(id: id) if persisted?
    errors.add(:name, :taken) if scope.exists?
  end

  def at_least_one_value
    kept_values = table_dropdown_values.reject(&:marked_for_destruction?)
    return if kept_values.any? { |value| value.label.present? }

    errors.add(:base, "Agregá al menos un valor.")
  end

  def ensure_not_in_use
    return unless table_cells.exists?

    errors.add(:base, "No se puede eliminar porque hay celdas que lo usan.")
    throw(:abort)
  end
end
