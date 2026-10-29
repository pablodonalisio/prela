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
    def build_copy(source)
      copy = new(name: available_copy_name(source.name))
      source.sections.with_details.each do |section|
        copy_section(copy, section)
      end
      copy
    end

    def available_copy_name(name)
      base = "#{name} (copia)"
      candidate = base
      suffix = 2

      while exists?(normalized_name: normalize_name(candidate))
        candidate = "#{base} #{suffix}"
        suffix += 1
      end

      candidate
    end

    def normalize_name(value)
      ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
    end

    private

    def copy_section(copy, source)
      section = copy.sections.build(
        title: source.title,
        position: source.position,
        kind: source.kind
      )

      case source.kind
      when "text"
        section.build_text_section
      when "images"
        section.build_image_section
      when "table"
        copy_table_section(section, source.table_section)
      when "list"
        copy_list_section(section, source.list_section)
      end
    end

    def copy_table_section(section, source)
      table = section.build_table_section(
        row_count: source.row_count,
        column_count: source.column_count
      )
      source.table_cells.each do |cell|
        copied = table.table_cells.build(
          row_index: cell.row_index,
          column_index: cell.column_index,
          value_type: cell.value_type,
          value: cell.value,
          for_metrics: cell.for_metrics,
          fixed: cell.fixed,
          table_dropdown_id: cell.table_dropdown_id
        )
        cell.table_cell_options.each do |option|
          copied.table_cell_options.build(value: option.value, label: option.label)
        end
      end
      source.table_labels.each do |label|
        table.table_labels.build(axis: label.axis, position: label.position, label: label.label)
      end
    end

    def copy_list_section(section, source)
      list = section.build_list_section
      source.list_items.each do |item|
        list.list_items.build(name: item.name, position: item.position)
      end
    end
  end
end
