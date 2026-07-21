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
  has_many :report_comments, -> { order(:position) }, dependent: :destroy, inverse_of: :report
  has_and_belongs_to_many :signatures

  accepts_nested_attributes_for :ups_report_stat, :power_unit_report_stat, :electrical_panel_report_stat, :room_report_stat
  accepts_nested_attributes_for :report_tasks, allow_destroy: true, reject_if: :reject_blank_report_task
  accepts_nested_attributes_for :report_comments, allow_destroy: true, reject_if: :reject_blank_report_comment

  before_validation :seed_tasks_from_template, on: :create
  before_validation :seed_comments_from_previous_report, on: :create
  before_validation :normalize_task_positions
  before_validation :normalize_comment_positions
  before_create :assign_number, if: :template_based?

  validates :date, presence: true
  validates :report_template, presence: true, if: :template_based?
  validate :report_template_must_exist, if: :template_based?
  validate :validate_field_values_match_template, if: :template_based?
  validate :images_count_within_limit
  validate :number_unique_for_equipment_and_year, if: -> { number.present? && date.present? }

  def template_based?
    report_template_id.present?
  end

  def report_code
    return unless template_based? && number.present? && date.present?

    [
      format("C%03d", location_equipment.client.id),
      format("A%04d", location_equipment.id),
      date.strftime("%y"),
      format("%03d", number)
    ].join("-")
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

  def build_comments_from_previous_report!
    report_comments.target.clear
    previous_report_comments_for_seed.each do |comment|
      report_comments.build(
        description: comment.description,
        position: comment.position
      )
    end
  end

  def report_tasks_attributes=(attributes)
    @report_tasks_attributes_assigned = true
    super
  end

  def report_comments_attributes=(attributes)
    @report_comments_attributes_assigned = true
    super
  end

  private

  def assign_number
    return if number.present? || date.blank? || location_equipment.blank?

    self.number = next_number_for_equipment_year
  end

  def next_number_for_equipment_year
    year_scope = location_equipment.reports.where.not(number: nil).where(date: date.beginning_of_year..date.end_of_year)
    (year_scope.maximum(:number) || 0) + 1
  end

  def number_unique_for_equipment_and_year
    scope = self.class.where(location_equipment_id: location_equipment_id, number: number)
      .where(date: date.beginning_of_year..date.end_of_year)
    scope = scope.where.not(id: id) if persisted?
    return unless scope.exists?

    errors.add(:number, :taken)
  end

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

  def seed_comments_from_previous_report
    return unless template_based?
    return if @report_comments_attributes_assigned
    return if report_comments.reject(&:marked_for_destruction?).any?

    previous_report_comments_for_seed.each do |comment|
      report_comments.build(
        description: comment.description,
        position: comment.position
      )
    end
  end

  def previous_report_for_comments
    scope = location_equipment.reports.where.not(report_template_id: nil)
    scope = scope.where.not(id: id) if persisted?
    scope.order(date: :desc, id: :desc).first
  end

  def previous_report_comments_for_seed
    previous = previous_report_for_comments
    return [] if previous.blank?

    previous.report_comments.reset
    previous.report_comments.to_a
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

  def normalize_comment_positions
    report_comments.reject(&:marked_for_destruction?).each_with_index do |comment, index|
      comment.position = index
    end
  end

  def reject_blank_report_task(attributes)
    attributes["name"].blank? && attributes["id"].blank?
  end

  def reject_blank_report_comment(attributes)
    attributes["description"].blank? && attributes["id"].blank?
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
