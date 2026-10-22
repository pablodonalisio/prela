class TableCell < ApplicationRecord
  VALUE_TYPES = %w[string integer float date boolean].freeze
  NUMERIC_TYPES = %w[integer float].freeze
  FIXABLE_TYPES = %w[string integer float].freeze

  belongs_to :table_section
  has_many :table_cell_options, dependent: :destroy, autosave: true, inverse_of: :table_cell

  accepts_nested_attributes_for :table_cell_options, allow_destroy: true

  validates :value_type, inclusion: {in: VALUE_TYPES}
  validates :row_index, :column_index, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validate :value_matches_type
  validate :metrics_only_on_numeric_types
  validate :fixed_only_on_fixable_types

  before_validation :clear_value_unless_fixed_on_template, :normalize_decimal_value, :sync_boolean_options

  def numeric?
    NUMERIC_TYPES.include?(value_type)
  end

  def fixable?
    FIXABLE_TYPES.include?(value_type)
  end

  def boolean?
    value_type == "boolean"
  end

  def option_at(state)
    cast = boolean_cast(state)
    return if cast.nil?

    table_cell_options.find { |option| !option.marked_for_destruction? && boolean_cast(option.value) == cast }
  end

  def ensure_option(state)
    option_at(state) || table_cell_options.build(value: state, label: "")
  end

  def option_label(state)
    text = option_at(state)&.label
    return text if text.present?

    boolean_cast(state) ? "Sí" : "No"
  end

  def choice
    return "fixed" if fixed?
    return "metrics" if for_metrics?

    ""
  end

  def choice=(value)
    case value.to_s
    when "fixed"
      self.fixed = true
      self.for_metrics = false
    when "metrics"
      self.fixed = false
      self.for_metrics = true
    else
      self.fixed = false
      self.for_metrics = false
    end
  end

  private

  def sync_boolean_options
    return if marked_for_destruction?

    if boolean?
      [true, false].each do |state|
        table_cell_options.build(value: state, label: "") unless option_at(state)
      end
    else
      table_cell_options.each do |option|
        option.mark_for_destruction unless option.marked_for_destruction?
      end
    end
  end

  def boolean_cast(state)
    ActiveModel::Type::Boolean.new.cast(state)
  end

  def normalize_decimal_value
    return unless value_type == "float"
    return if value.blank?

    normalized = value.to_s.strip.gsub(/[[:space:]]/, "")
    if normalized.match?(/\A-?\d{1,3}(\.\d{3})*,\d+\z/) || normalized.match?(/\A-?\d+,\d+\z/)
      normalized = normalized.delete(".").tr(",", ".")
    end
    self.value = normalized
  end

  def clear_value_unless_fixed_on_template
    return if fixed?
    return unless table_section&.owned_by_template?

    self.value = nil
  end

  def value_matches_type
    return if value.blank?

    case value_type
    when "integer"
      Integer(value)
    when "float"
      Float(value)
    when "boolean"
      return if [true, false, "0", "1", 0, 1, "true", "false"].include?(value)

      raise ArgumentError
    when "date"
      Date.parse(value.to_s)
    end
  rescue ArgumentError, TypeError
    errors.add(:value, "de la fila #{row_index.to_i + 1}, columna #{column_index.to_i + 1} no es válido.")
  end

  def metrics_only_on_numeric_types
    return unless for_metrics?
    return if numeric?

    errors.add(:for_metrics, "solo se permite en valores numéricos.")
  end

  def fixed_only_on_fixable_types
    return unless fixed?
    return if fixable?

    errors.add(:fixed, "no se permite en fecha o booleano.")
  end
end
