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
  has_many :report_template_tasks, -> { order(:position) }, dependent: :destroy, inverse_of: :report_template

  accepts_nested_attributes_for :report_template_tasks, allow_destroy: true, reject_if: :reject_blank_task

  before_validation :set_normalized_name, :normalize_field_positions, :normalize_task_positions

  validates :name, presence: true
  validate :name_must_be_unique
  validate :validate_section_field_definitions

  def active_sections
    self.class::SECTIONS.filter { |section| fields_for(section).present? }
  end

  def location_equipments_count
    location_equipments.size
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

  def reject_blank_task(attributes)
    attributes["name"].blank? && attributes["id"].blank?
  end
end
