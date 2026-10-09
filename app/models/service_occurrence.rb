class ServiceOccurrence < ApplicationRecord
  include Filterable
  include Prioritizable

  DUE_SOON_WINDOW = 3.months
  OPEN_STATUSES = %w[pending suspended scheduled].freeze

  belongs_to :location_equipment_service

  has_one_attached :document

  before_validation :inherit_priority_from_service_kind, on: :create

  delegate :location_equipment, :service_kind, to: :location_equipment_service

  enum :status, {pending: 0, completed: 1, suspended: 2, scheduled: 3, cancelled: 4}

  validates :due_on, presence: true, if: :open?
  validates :planned_on_init, :planned_on_finish, presence: true, if: :scheduled?
  validates :completed_on, presence: true, if: :completed?
  validates :status, presence: true
  validate :planned_on_init_not_before_today, if: :scheduled?
  validate :planned_on_finish_after_init, if: :scheduled?
  validate :only_one_open_per_location_equipment_service, if: :open?

  before_save :clear_schedule_unless_kept

  scope :open, -> { where(status: OPEN_STATUSES) }
  scope :suspended, -> { where(status: :suspended) }
  scope :scheduled, -> { where(status: :scheduled) }
  scope :for_visible_location_equipments, -> {
    joins(location_equipment_service: :location_equipment)
      .where(location_equipment_services: {location_equipment_id: LocationEquipment.visible.select(:id)})
  }
  scope :overdue, -> {
    open.where(service_occurrences: {due_on: ...Date.current})
  }
  scope :due_soon, -> {
    open.where(due_on: Date.current...due_soon_until)
  }
  scope :due_for_attention, -> {
    open.where("service_occurrences.due_on < ?", due_soon_until)
  }
  scope :actionable_for_attention, -> {
    pending.where("service_occurrences.due_on < ?", due_soon_until)
  }
  scope :for_control_panel, -> {
    where(
      "(service_occurrences.status = :pending AND service_occurrences.due_on < :until) OR service_occurrences.status = :suspended",
      pending: statuses[:pending],
      until: due_soon_until,
      suspended: statuses[:suspended]
    )
  }
  scope :for_agenda, ->(range) {
    where(
      <<~SQL.squish,
        (service_occurrences.status = :scheduled AND (service_occurrences.planned_on_init::date BETWEEN :from AND :to))
        OR (service_occurrences.status IN (:pending, :suspended) AND service_occurrences.due_on BETWEEN :from AND :to)
      SQL
      scheduled: statuses[:scheduled],
      pending: statuses[:pending],
      suspended: statuses[:suspended],
      from: range.begin,
      to: range.end
    ).order(Arel.sql("COALESCE(service_occurrences.planned_on_init, service_occurrences.due_on::timestamp)"))
  }
  scope :by_client_id, ->(client_id) {
    joins(location_equipment_service: {location_equipment: :location})
      .where(locations: {client_id: client_id})
  }
  scope :by_service_kind_id, ->(service_kind_id) {
    joins(location_equipment_service: :service_kind)
      .where(service_kinds: {id: service_kind_id})
  }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_kind, ->(legacy_key) {
    joins(location_equipment_service: :service_kind)
      .where(service_kinds: {legacy_key: legacy_key})
  }

  def open?
    pending? || suspended? || scheduled?
  end

  def overdue?
    open? && due_on < Date.current
  end

  def due_soon?
    open? && due_on >= Date.current && due_on < self.class.due_soon_until
  end

  def status_label
    I18n.t("activerecord.attributes.service_occurrence.statuses.#{status}")
  end

  def agenda_date
    scheduled? ? planned_on_init : due_on
  end

  def service_date
    return planned_on_init if scheduled? && planned_on_init.present?
    return completed_on if completed? && completed_on.present?

    due_on
  end

  class << self
    def due_soon_until
      DUE_SOON_WINDOW.from_now.to_date
    end

    def due_for_attention_by_equipment_kind(scope = all)
      scope.actionable_for_attention
        .for_visible_location_equipments
        .includes(location_equipment_service: {location_equipment: [{equipment: :equipment_kind}, {location: :client}], service_kind: []})
        .group_by { |occurrence| occurrence.location_equipment.equipment.equipment_kind }
    end

    def control_panel_by_equipment_kind(scope = all)
      scope.for_control_panel
        .for_visible_location_equipments
        .includes(location_equipment_service: {location_equipment: [{equipment: :equipment_kind}, {location: :client}], service_kind: []})
        .group_by { |occurrence| occurrence.location_equipment.equipment.equipment_kind }
    end

    def suspended_by_equipment_kind(scope = all)
      scope.suspended
        .for_visible_location_equipments
        .includes(location_equipment_service: {location_equipment: [{equipment: :equipment_kind}, {location: :client}], service_kind: []})
        .group_by { |occurrence| occurrence.location_equipment.equipment.equipment_kind }
    end
  end

  private

  def clear_schedule_unless_kept
    return if scheduled? || completed?

    self.planned_on_init = nil
    self.planned_on_finish = nil
  end

  def planned_on_init_not_before_today
    return if planned_on_init.blank?
    return if planned_on_init.to_date >= Date.current

    errors.add(:planned_on_init, :before_today)
  end

  def planned_on_finish_after_init
    return if planned_on_init.blank? || planned_on_finish.blank?
    return if planned_on_finish > planned_on_init

    errors.add(:planned_on_finish, :after_start)
  end

  def inherit_priority_from_service_kind
    return if location_equipment_service.blank?
    return if service_kind.blank?

    self.priority = service_kind.priority
  end

  def only_one_open_per_location_equipment_service
    return unless open?

    existing = self.class.open
      .where(location_equipment_service_id: location_equipment_service_id)
      .where.not(id: id)

    errors.add(:status, :taken) if existing.exists?
  end
end
