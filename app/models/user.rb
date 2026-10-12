class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable

  belongs_to :client, optional: true

  has_many :service_occurrence_assignments, dependent: :destroy
  has_many :assigned_service_occurrences, through: :service_occurrence_assignments, source: :service_occurrence

  enum :role, {client: 0, admin: 1, technician: 2}

  validates :role, presence: true
  validates :editor, inclusion: {in: [true, false]}

  scope :with_kept_client, -> {
    left_joins(:client).where("users.client_id IS NULL OR clients.discarded_at IS NULL")
  }

  def active_for_authentication?
    super && client_kept_for_authentication?
  end

  def inactive_message
    client_discarded_for_authentication? ? :client_discarded : super
  end

  def self.unavailable_ids_for(range, except: nil)
    init = range.begin
    finish = range.end
    return [] if init.blank? || finish.blank?

    scope = joins(:assigned_service_occurrences)
      .where(service_occurrences: {status: ServiceOccurrence.statuses[:scheduled]})
      .where("service_occurrences.planned_on_init < ?", finish)
      .where("service_occurrences.planned_on_finish > ?", init)
    scope = scope.where.not(service_occurrences: {id: except.id}) if except&.id.present?
    scope.distinct.pluck(:id)
  end

  def full_role
    case role
    when "admin" then "Admin"
    when "technician" then "Técnico"
    when "client" then "Cliente#{editor? ? " (Editor)" : ""}"
    else
      raise StandardError, "Undefined role"
    end
  end

  private

  def client_kept_for_authentication?
    admin? || technician? || client_id.nil? || client&.kept?
  end

  def client_discarded_for_authentication?
    client_id.present? && client&.discarded?
  end
end
