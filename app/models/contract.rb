class Contract < ApplicationRecord
  include Discard::Model

  ACCEPTED_CONTENT_TYPES = %w[
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    image/jpeg
    image/png
  ].freeze

  belongs_to :client
  has_many_attached :files

  attr_accessor :removed_file_blob_ids

  validates :name, :starts_on, :ends_on, presence: true
  validate :files_present
  validate :acceptable_files
  validate :ends_on_on_or_after_starts_on

  scope :visible, -> { kept }

  private

  def files_present
    errors.add(:files, :blank) if kept_files.empty?
  end

  def acceptable_files
    return if kept_files.all? { |file| ACCEPTED_CONTENT_TYPES.include?(file.content_type) }

    errors.add(:files, "debe ser PDF, Word, JPEG o PNG")
  end

  def kept_files
    removed_ids = Array(removed_file_blob_ids).map(&:to_i)
    files.reject { |file| removed_ids.include?(file.blob_id) }
  end

  def ends_on_on_or_after_starts_on
    return if starts_on.blank? || ends_on.blank?
    return if ends_on >= starts_on

    errors.add(:ends_on, "debe ser posterior o igual a la fecha de inicio")
  end
end
