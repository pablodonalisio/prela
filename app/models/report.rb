class Report < ApplicationRecord
  include ReportFieldValuesValidatable

  MAX_IMAGES = 10

  belongs_to :location_equipment
  belongs_to :report_template, optional: true

  has_one_attached :pdf
  has_many_attached :images
  has_one :ups_report_stat, dependent: :destroy
  has_one :power_unit_report_stat, dependent: :destroy
  has_one :electrical_panel_report_stat, dependent: :destroy
  has_one :room_report_stat, dependent: :destroy
  has_many :report_tasks, -> { order(:position) }, dependent: :destroy, inverse_of: :report

  accepts_nested_attributes_for :ups_report_stat, :power_unit_report_stat, :electrical_panel_report_stat, :room_report_stat
  accepts_nested_attributes_for :report_tasks, allow_destroy: true, reject_if: :reject_blank_report_task

  before_validation :seed_tasks_from_template, on: :create
  before_validation :normalize_task_positions

  validates :date, presence: true
  validates :report_template, presence: true, if: :template_based?
  validate :report_template_must_exist, if: :template_based?
  validate :validate_field_values_match_template, if: :template_based?
  validate :images_count_within_limit

  def template_based?
    report_template_id.present?
  end

  def field_values_for(section)
    field_values.fetch(section.to_s, {})
  end

  def build_tasks_from_template!
    return unless report_template

    report_tasks.target.clear
    template_tasks_for_seed.each do |template_task|
      report_tasks.build(
        name: template_task.name,
        position: template_task.position,
        completed: false
      )
    end
  end

  def report_tasks_attributes=(attributes)
    @report_tasks_attributes_assigned = true
    super
  end

  private

  def seed_tasks_from_template
    return unless template_based?
    return if @report_tasks_attributes_assigned
    return if report_tasks.reject(&:marked_for_destruction?).any?
    return if report_template.blank?

    template_tasks_for_seed.each do |template_task|
      report_tasks.build(
        name: template_task.name,
        position: template_task.position,
        completed: false
      )
    end
  end

  def template_tasks_for_seed
    report_template.report_template_tasks.reset
    report_template.report_template_tasks.to_a
  end

  def normalize_task_positions
    report_tasks.reject(&:marked_for_destruction?).each_with_index do |task, index|
      task.position = index
    end
  end

  def reject_blank_report_task(attributes)
    attributes["name"].blank? && attributes["id"].blank?
  end

  def report_template_must_exist
    return if ReportTemplate.exists?(report_template_id)

    errors.add(:report_template, :invalid)
  end

  def images_count_within_limit
    return unless images.attached?

    errors.add(:images, "no puede tener más de #{MAX_IMAGES} imágenes.") if images.count > MAX_IMAGES
  end
end
