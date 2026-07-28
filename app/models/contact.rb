class Contact < ApplicationRecord
  include Discard::Model

  belongs_to :client
  belongs_to :location, optional: true
  belongs_to :reports_to, class_name: "Contact", optional: true
  has_many :direct_reports, class_name: "Contact", foreign_key: :reports_to_id, dependent: :nullify,
    inverse_of: :reports_to

  validates :name, :work_area, :job_position, presence: true
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, allow_blank: true
  validate :location_belongs_to_client
  validate :reports_to_belongs_to_client
  validate :reports_to_must_not_create_cycle

  after_discard :nullify_direct_reports

  scope :visible, -> { kept }
  scope :roots, -> { kept.where(reports_to_id: nil) }

  private

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
