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

  accepts_nested_attributes_for :ups_report_stat, :power_unit_report_stat, :electrical_panel_report_stat, :room_report_stat

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

  private

  def report_template_must_exist
    return if ReportTemplate.exists?(report_template_id)

    errors.add(:report_template, :invalid)
  end

  def images_count_within_limit
    return unless images.attached?

    errors.add(:images, "no puede tener más de #{MAX_IMAGES} imágenes.") if images.count > MAX_IMAGES
  end
end
