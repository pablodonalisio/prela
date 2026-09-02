class ServiceOccurrence < ApplicationRecord
  include Filterable

  DUE_SOON_WINDOW = 3.months
  OPEN_STATUSES = %w[pending suspended scheduled].freeze

  belongs_to :location_equipment_service

  has_one_attached :document

  delegate :location_equipment, :service_kind, to: :location_equipment_service

  enum :status, {pending: 0, completed: 1, suspended: 2, scheduled: 3, cancelled: 4}

  validates :due_on, presence: true, if: :open?
  validates :planned_on, presence: true, if: :scheduled?
  validates :completed_on, presence: true, if: :completed?
  validates :status, presence: true
  validate :only_one_open_per_location_equipment_service, if: :open?

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
  scope :for_agenda, ->(range) {
    scheduled.where(planned_on: range).order(:planned_on)
  }
  scope :by_client_id, ->(client_id) {
    joins(location_equipment_service: {location_equipment: :location})
      .where(locations: {client_id: client_id})
  }
  scope :by_service_kind_id, ->(service_kind_id) {
    joins(location_equipment_service: :service_kind)
      .where(service_kinds: {id: service_kind_id})
  }
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

  class << self
    def due_soon_until
      DUE_SOON_WINDOW.from_now.to_date
    end

    def due_for_attention_by_equipment_kind(scope = all)
      scope.actionable_for_attention
        .for_visible_location_equipments
        .includes(location_equipment_service: {location_equipment: [:equipment, {location: :client}], service_kind: []})
        .group_by { |occurrence| occurrence.location_equipment.equipment.kind }
    end

    def suspended_by_equipment_kind(scope = all)
      scope.suspended
        .for_visible_location_equipments
        .includes(location_equipment_service: {location_equipment: [:equipment, {location: :client}], service_kind: []})
        .group_by { |occurrence| occurrence.location_equipment.equipment.kind }
    end
  end

  private

  def only_one_open_per_location_equipment_service
    return unless open?

    existing = self.class.open
      .where(location_equipment_service_id: location_equipment_service_id)
      .where.not(id: id)

    errors.add(:status, :taken) if existing.exists?
  end
end
