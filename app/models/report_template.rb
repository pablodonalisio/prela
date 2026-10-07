class ReportTemplate < ApplicationRecord
  include FieldDefinitionsValidatable

  FIELD_TYPES = FieldDefinitionsValidatable::FIELD_TYPES
  SECTIONS = %w[
    equipment_specifications
    location_specifications
    measurements
    room_specifications
  ].freeze
  FIXED_SECTIONS = %w[equipment_specifications location_specifications].freeze
  MOVABLE_SINGLETONS = %w[measurements room_specifications tasks].freeze
  REPEATABLE_BLOCK_TYPES = %w[observations images].freeze
  LAYOUT_BLOCK_TYPES = (MOVABLE_SINGLETONS + REPEATABLE_BLOCK_TYPES).freeze

  has_and_belongs_to_many :location_equipments
  has_many :reports, dependent: :restrict_with_error
  has_many :report_template_tasks, -> { order(:position) }, dependent: :destroy, inverse_of: :report_template

  accepts_nested_attributes_for :report_template_tasks, allow_destroy: true, reject_if: :reject_blank_task

  before_validation :set_normalized_name, :normalize_field_positions, :normalize_task_positions, :normalize_layout

  validates :name, presence: true
  validate :name_must_be_unique
  validate :validate_section_field_definitions
  validate :repeatable_blocks_require_titles

  def active_sections
    self.class::SECTIONS.filter { |section| fields_for(section).present? }
  end

  def layout_blocks
    blocks = []
    seen_ids = {}

    layout_entries.each do |raw|
      block = sanitize_layout_block(raw)
      next if block.nil?
      next if seen_ids[block["id"]]
      next if MOVABLE_SINGLETONS.include?(block["type"]) && blocks.any? { |existing| existing["type"] == block["type"] }

      seen_ids[block["id"]] = true
      blocks << block
    end

    MOVABLE_SINGLETONS.each do |type|
      next if blocks.any? { |block| block["type"] == type }

      blocks << {"id" => type, "type" => type}
    end

    blocks
  end

  def block_ids_for(type)
    layout_blocks.select { |block| block["type"] == type }.map { |block| block["id"] }
  end

  def block_title(block)
    data = block.respond_to?(:stringify_keys) ? block.stringify_keys : {}
    title = data["title"].to_s.strip
    return title if title.present?

    case data["type"]
    when "observations" then I18n.t("activerecord.attributes.report_template.observations")
    when "images" then I18n.t("activerecord.attributes.report_template.images")
    else ""
    end
  end

  def location_equipments_count
    location_equipments.merge(LocationEquipment.visible).size
  end

  def fields_for(section)
    fields = public_send(section).presence || {}
    return {} if fields.blank?

    fields.sort_by.with_index do |(key, data), index|
      position = data["position"]
      sort_position = position.present? ? position.to_i : index
      [sort_position, key.to_i]
    end.to_h
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

  def normalize_field_positions
    SECTIONS.each do |section|
      fields = public_send(section)
      next if fields.blank?

      ordered_keys = fields.sort_by.with_index do |(key, data), index|
        position = data["position"]
        sort_position = position.present? ? position.to_i : index
        [sort_position, key.to_i]
      end.map(&:first)

      ordered_keys.each_with_index do |key, index|
        fields[key]["position"] = index
      end
    end
  end

  def normalize_task_positions
    report_template_tasks.reject(&:marked_for_destruction?).each_with_index do |task, index|
      task.position = index
    end
  end

  def normalize_layout
    self.layout = layout_blocks
  end

  def repeatable_blocks_require_titles
    missing_title = layout_blocks.any? do |block|
      REPEATABLE_BLOCK_TYPES.include?(block["type"]) && block["title"].blank?
    end
    return unless missing_title

    errors.add(:layout, I18n.t("activerecord.attributes.report_template.section_title_blank"))
  end

  def layout_entries
    value = layout
    if value.is_a?(Array)
      value = value.map { |entry| entry.respond_to?(:to_unsafe_h) ? entry.to_unsafe_h : entry }
    elsif value.respond_to?(:to_unsafe_h)
      value = value.to_unsafe_h
    end

    case value
    when Array
      value
    when Hash
      value.sort_by { |key, _| Integer(key.to_s, exception: false) || key.to_s }.map(&:last)
    else
      []
    end
  end

  def sanitize_layout_block(raw)
    data = raw.respond_to?(:stringify_keys) ? raw.stringify_keys : {}
    type = data["type"].to_s
    return unless LAYOUT_BLOCK_TYPES.include?(type)

    if MOVABLE_SINGLETONS.include?(type)
      {"id" => type, "type" => type}
    else
      id = data["id"].to_s
      return if id.blank? || MOVABLE_SINGLETONS.include?(id)
      return unless id.match?(/\A[a-zA-Z0-9_-]+\z/)

      block = {"id" => id, "type" => type}
      title = data["title"].to_s.strip.squish
      block["title"] = title[0, 120] if title.present?
      block
    end
  end

  def reject_blank_task(attributes)
    attributes["name"].blank? && attributes["id"].blank?
  end
end
