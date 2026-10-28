class TableDropdownValue < ApplicationRecord
  belongs_to :table_dropdown, inverse_of: :table_dropdown_values

  validates :label, presence: true
  validates :position, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validate :label_unique_in_dropdown

  before_validation :strip_label

  private

  def strip_label
    self.label = label.to_s.strip
  end

  def label_unique_in_dropdown
    return if label.blank? || table_dropdown.nil?

    normalized = TableDropdown.normalize_name(label)
    siblings = table_dropdown.table_dropdown_values.reject(&:marked_for_destruction?)
    duplicate = siblings.any? do |other|
      other != self && other.label.present? && TableDropdown.normalize_name(other.label) == normalized
    end
    errors.add(:label, :taken) if duplicate
  end
end
