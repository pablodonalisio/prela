class ServiceDate < ApplicationRecord
  include Filterable

  belongs_to :location_equipment
  belongs_to :activity, optional: true

  enum :kind, {service: 0, battery_change: 1, belt_change: 2, torque: 3, cleaning: 4, srt_900: 5, thermography: 6, electrical_approval: 7}

  validates :kind, :date, presence: true

  after_commit :sync_pending_service_occurrence, on: %i[create update]
  after_commit :sync_pending_service_occurrence_after_destroy, on: :destroy

  scope :by_kind, ->(kind) { where(kind:) }
  scope :by_client_id, ->(client_id) {
    joins(location_equipment: {location: :client}).where(clients: {id: client_id})
  }
  scope :for_visible_location_equipments, -> {
    where(location_equipment_id: LocationEquipment.visible.select(:id))
  }

  class << self
    def next_service_dates(selected_columns = "*")
      select("DISTINCT ON (location_equipment_id, kind) #{selected_columns}").order(:location_equipment_id, :kind, date: :desc)
    end

    def overdue_next_service_dates
      subquery = next_service_dates("service_dates.id").to_sql
      for_visible_location_equipments
        .includes(:location_equipment)
        .where("service_dates.id IN (#{subquery}) AND date < ?", 3.months.from_now)
    end

    def overdue_next_service_dates_by_equipment_kind
      overdue_next_service_dates.includes(location_equipment: [:equipment, :location]).group_by { |sd| sd.location_equipment.equipment.kind }
    end
  end

  private

  def sync_pending_service_occurrence
    sync_pending_service_occurrence_for(location_equipment, kind)
  end

  def sync_pending_service_occurrence_after_destroy
    location_equipment = LocationEquipment.find_by(id: location_equipment_id)
    return if location_equipment.nil?

    sync_pending_service_occurrence_for(location_equipment, kind)
  end

  def sync_pending_service_occurrence_for(location_equipment, service_kind_key)
    les = location_equipment.location_equipment_service_for(service_kind_key)
    return if les.nil?

    latest_service_date = location_equipment.service_dates.where(kind: service_kind_key).order(date: :desc).first

    if latest_service_date.nil?
      les.service_occurrences.pending.destroy_all
      return
    end

    occurrence = les.service_occurrences.pending.first_or_initialize
    occurrence.due_on = latest_service_date.date.to_date
    occurrence.save!
  end
end

