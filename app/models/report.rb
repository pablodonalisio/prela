class Report < ApplicationRecord
  MAX_IMAGES = 10
  MAX_UPLOADED_FILES = 20
  UPLOADED_CONTENT_TYPES = %w[application/pdf image/jpeg image/jpg image/png].freeze

  belongs_to :location_equipment
  belongs_to :report_template, optional: true

  has_one_attached :pdf
  has_many_attached :files
  has_many_attached :images
  has_one :ups_report_stat, dependent: :destroy
  has_one :power_unit_report_stat, dependent: :destroy
  has_one :electrical_panel_report_stat, dependent: :destroy
  has_one :room_report_stat, dependent: :destroy
  has_many :sections, -> { order(:position) }, as: :sectionable, dependent: :destroy, inverse_of: :sectionable, autosave: true
  has_many :table_dropdowns, dependent: :destroy, autosave: true, inverse_of: :report
  has_and_belongs_to_many :signatures

  attr_accessor :allowed_signatures, :section_inputs, :sections_copied_from_template, :removed_file_blob_ids

  accepts_nested_attributes_for :ups_report_stat, :power_unit_report_stat, :electrical_panel_report_stat, :room_report_stat

  before_validation :mark_template_based, on: :create
  before_validation :seed_sections_from_template, on: :create
  before_validation :apply_section_inputs
  before_create :assign_number, if: :template_based?

  validates :date, presence: true
  validate :report_template_must_exist, on: :create, if: -> { report_template_id.present? }
  validate :images_count_within_limit
  validate :number_unique_for_equipment_and_year, if: -> { number.present? && date.present? }
  validate :signatures_must_be_selectable, if: :validate_signatures?
  validate :uploaded_files_must_be_present, if: :uploaded?
  validate :uploaded_files_must_be_documents, if: :uploaded?
  validate :uploaded_files_count_within_limit, if: :uploaded?

  def report_code
    return unless template_based? && number.present? && date.present?

    [
      format("C%03d", location_equipment.client.id),
      format("A%04d", location_equipment.id),
      date.strftime("%y"),
      format("%03d", number)
    ].join("-")
  end

  def signature_ids=(ids)
    @submitted_signature_ids = Array(ids).reject(&:blank?).map(&:to_i)
    remember_linked_signature_ids
    @validate_signatures = true
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

  def mark_template_based
    self.template_based = true if report_template_id.present?
  end

  def seed_sections_from_template
    Reports::CopyTemplateSections.call(self)
  end

  def apply_section_inputs
    return if sections_copied_from_template
    
    Reports::ApplySectionInputs.call(self)
  ensure
    self.sections_copied_from_template = false
  end

  def report_template_must_exist
    return if ReportTemplate.exists?(report_template_id)

    errors.add(:report_template, :invalid)
  end

  def images_count_within_limit
    return unless images.attached?

    errors.add(:images, "no puede tener más de #{MAX_IMAGES} imágenes.") if images.count > MAX_IMAGES
  end

  def uploaded_files_must_be_present
    errors.add(:files, :blank) if kept_uploaded_files.empty?
  end

  def uploaded_files_must_be_documents
    return if kept_uploaded_files.all? { |file| UPLOADED_CONTENT_TYPES.include?(file.content_type) }

    errors.add(:files, "debe ser PDF, JPEG o PNG")
  end

  def uploaded_files_count_within_limit
    return if kept_uploaded_files.size <= MAX_UPLOADED_FILES

    errors.add(:files, "no puede tener más de #{MAX_UPLOADED_FILES} archivos")
  end

  def kept_uploaded_files
    removed_ids = Array(removed_file_blob_ids).map(&:to_i)
    files.reject { |file| removed_ids.include?(file.blob_id) }
  end

  def validate_signatures?
    @validate_signatures && !allowed_signatures.nil?
  end

  def remember_linked_signature_ids
    return if defined?(@previously_linked_signature_ids)

    @previously_linked_signature_ids = persisted? ? signature_ids : []
  end

  def signatures_must_be_selectable
    selectable_ids = allowed_signatures.where(id: @submitted_signature_ids).pluck(:id)
    rejected_ids = @submitted_signature_ids - selectable_ids - @previously_linked_signature_ids
    return if rejected_ids.empty?

    errors.add(:signatures, "incluye una firma que no se puede usar")
  end
end
