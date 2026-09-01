class ServiceOccurrence < ApplicationRecord
  include Filterable

  DUE_SOON_WINDOW = 3.months

  belongs_to :location_equipment_service

  has_one_attached :document

  delegate :location_equipment, :service_kind, to: :location_equipment_service

  enum :status, {pending: 0, completed: 1}

  validates :due_on, presence: true, if: :pending?
  validates :completed_on, presence: true, if: :completed?
  validates :status, presence: true
  validate :only_one_pending_per_location_equipment_service, if: :pending?

  scope :open, -> { pending }
  scope :for_visible_location_equipments, -> {
    joins(location_equipment_service: :location_equipment)
      .where(location_equipment_services: {location_equipment_id: LocationEquipment.visible.select(:id)})
  }
  scope :overdue, -> {
    pending.where(service_occurrences: {due_on: ...Date.current})
  }
  scope :due_soon, -> {
    pending.where(due_on: Date.current...due_soon_until)
  }
  scope :due_for_attention, -> {
    pending.where("service_occurrences.due_on < ?", due_soon_until)
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

  def overdue?
    pending? && due_on < Date.current
  end

  def due_soon?
    pending? && due_on >= Date.current && due_on < self.class.due_soon_until
  end

  def complete!(completed_on:, document: nil)
    raise ArgumentError, "only pending occurrences can be completed" unless pending?

    transaction do
      update!(status: :completed, completed_on: completed_on.to_date, due_on: completed_on.to_date)
      document.present? ? self.document.attach(document) : nil

      les = location_equipment_service
      if les.recurring?
        les.service_occurrences.create!(
          status: :pending,
          due_on: les.advance(completed_on.to_date)
        )
      end
    end
  end

  class << self
    def due_soon_until
      DUE_SOON_WINDOW.from_now.to_date
    end

    def due_for_attention_by_equipment_kind(scope = all)
      scope.due_for_attention
        .for_visible_location_equipments
        .includes(location_equipment_service: {location_equipment: [:equipment, {location: :client}], service_kind: []})
        .group_by { |occurrence| occurrence.location_equipment.equipment.kind }
    end
  end

  private

  def only_one_pending_per_location_equipment_service
    return unless pending?

    existing = self.class.pending
      .where(location_equipment_service_id: location_equipment_service_id)
      .where.not(id: id)

    errors.add(:status, :taken) if existing.exists?
  end
end
