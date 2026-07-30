class Contact < ApplicationRecord
  include Discard::Model

  belongs_to :client
  belongs_to :location, optional: true
  belongs_to :reports_to, class_name: "Contact", optional: true
  has_many :direct_reports, class_name: "Contact", foreign_key: :reports_to_id, dependent: :nullify,
    inverse_of: :reports_to

  validates :name, :work_area, :job_position, presence: true
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, allow_blank: true
  validates :distance_above, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validate :location_belongs_to_client
  validate :reports_to_belongs_to_client
  validate :reports_to_must_not_create_cycle
  validate :distance_above_must_be_positive_with_superior

  before_validation :assign_default_distance_above

  after_discard :nullify_direct_reports

  scope :visible, -> { kept }
  scope :roots, -> { kept.where(reports_to_id: nil) }

  # Extra vertical steps beyond the normal parent→child link (0 for a normal report).
  def organigram_extra_spacers
    reports_to_id.present? ? [distance_above - 1, 0].max : distance_above
  end

  def path_depth
    depth = distance_above
    ancestor = reports_to
    while ancestor
      depth += ancestor.distance_above
      ancestor = ancestor.reports_to
    end
    depth
  end

  private

  def assign_default_distance_above
    return if reports_to_id.blank?
    return if distance_above.present? && distance_above >= 1

    self.distance_above = 1
  end

  def distance_above_must_be_positive_with_superior
    return if reports_to_id.blank?
    return if distance_above.blank? || distance_above >= 1

    errors.add(:distance_above, "debe ser al menos 1 cuando tiene superior")
  end

  def location_belongs_to_client
    return if location_id.blank? || location.blank?

    errors.add(:location, "debe pertenecer al mismo cliente") if location.client_id != client_id
  end

  def reports_to_belongs_to_client
    return if reports_to_id.blank? || reports_to.blank?

    errors.add(:reports_to, "debe pertenecer al mismo cliente") if reports_to.client_id != client_id
  end

  def reports_to_must_not_create_cycle
    return if reports_to_id.blank?

    if persisted? && reports_to_id == id
      errors.add(:reports_to, "no puede reportar a sí mismo")
      return
    end

    ancestor = reports_to
    while ancestor
      if persisted? && ancestor.id == id
        errors.add(:reports_to, "crearía un ciclo en el organigrama")
        return
      end
      ancestor = ancestor.reports_to
    end
  end

  def nullify_direct_reports
    direct_reports.update_all(reports_to_id: nil)
  end
end
