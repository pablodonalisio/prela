class ServiceDate < ApplicationRecord
  include Filterable

  belongs_to :location_equipment
  belongs_to :activity, optional: true

  enum :kind, {service: 0, battery_change: 1, belt_change: 2, torque: 3, cleaning: 4, srt_900: 5, thermography: 6, electrical_approval: 7}

  validates :kind, :date, presence: true

  scope :by_kind, ->(kind) { where(kind:) }
  scope :by_client_id, ->(client_id) {
    joins(location_equipment: {location: :client}).where(clients: {id: client_id})
  }

  class << self
    def next_service_dates(selected_columns = "*")
      select("DISTINCT ON (location_equipment_id, kind) #{selected_columns}").order(:location_equipment_id, :kind, date: :desc)
    end

    def overdue_next_service_dates
      subquery = next_service_dates("service_dates.id").to_sql
      includes(:location_equipment).where("service_dates.id IN (#{subquery}) AND date < ?", 3.months.from_now)
    end

    def overdue_next_service_dates_by_equipment_kind
      overdue_next_service_dates.includes(location_equipment: [:equipment, :location]).group_by { |sd| sd.location_equipment.equipment.kind }
    end
  end
end
