class TableSection < ApplicationRecord
  MAX_ROWS = 16
  MAX_COLUMNS = 12

  belongs_to :section
  has_many :table_cells, -> { order(:row_index, :column_index) }, dependent: :destroy, autosave: true, inverse_of: :table_section
  has_many :table_labels, -> { order(:axis, :position) }, dependent: :destroy, autosave: true, inverse_of: :table_section

  accepts_nested_attributes_for :table_cells, :table_labels, allow_destroy: true

  validates :row_count, presence: true, numericality: {
    only_integer: true,
    greater_than: 0,
    less_than_or_equal_to: MAX_ROWS
  }
  validates :column_count, presence: true, numericality: {
    only_integer: true,
    greater_than: 0,
    less_than_or_equal_to: MAX_COLUMNS
  }
  validate :headers_titled_on_template

  before_validation :sync_cell_grid, :sync_label_grid

  def owned_by_template?
    owner = section
    return false if owner.blank?
    return false if owner.report.present? || owner.report_id.present?

    owner.report_template.present? || owner.report_template_id.present?
  end

  def cell_at(row, column)
    table_cells.find { |cell| cell.row_index == row && cell.column_index == column && !cell.marked_for_destruction? }
  end

  def label_at(axis, position)
    table_labels.find { |label| label.axis == axis && label.position == position && !label.marked_for_destruction? }
  end

  def column_label(position)
    label_at("column", position)&.label
  end

  def row_label(position)
    label_at("row", position)&.label
  end

  def corner_label
    label_at("corner", 0)&.label
  end

  def ensure_label(axis, position)
    label_at(axis, position) || table_labels.build(axis: axis, position: position, label: "")
  end

  private

  def sync_cell_grid
    return if marked_for_destruction?
    return unless row_count.to_i.between?(1, MAX_ROWS)
    return unless column_count.to_i.between?(1, MAX_COLUMNS)

    expected = {}
    row_count.times do |row|
      column_count.times do |column|
        expected[[row, column]] = true
      end
    end

    table_cells.each do |cell|
      next if cell.marked_for_destruction?

      key = [cell.row_index, cell.column_index]
      if expected.delete(key)
        next
      end

      cell.mark_for_destruction
    end

    expected.each_key do |row, column|
      table_cells.build(row_index: row, column_index: column, value_type: "string")
    end
  end

  def headers_titled_on_template
    return unless owned_by_template?

    untitled = table_labels.reject(&:marked_for_destruction?).select { |label| label.header? && label.label.blank? }
    return if untitled.empty?

    untitled.each { |label| label.errors.add(:label, :blank) unless label.errors.added?(:label, :blank) }
    errors.add(:base, "Todos los encabezados de filas y columnas deben tener título.")
  end

  def sync_label_grid
    return if marked_for_destruction?
    return unless row_count.to_i.between?(1, MAX_ROWS)
    return unless column_count.to_i.between?(1, MAX_COLUMNS)

    {"row" => row_count, "column" => column_count, "corner" => 1}.each do |axis, count|
      expected = count.times.index_with { true }
      table_labels.each do |label|
        next if label.marked_for_destruction? || label.axis != axis

        if expected.delete(label.position)
          next
        end

        label.mark_for_destruction
      end

      expected.each_key do |position|
        table_labels.build(axis: axis, position: position, label: "")
      end
    end
  end
end
