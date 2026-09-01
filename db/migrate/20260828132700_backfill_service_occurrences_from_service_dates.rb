class BackfillServiceOccurrencesFromServiceDates < ActiveRecord::Migration[8.0]
  class ServiceDate < ApplicationRecord
    self.table_name = "service_dates"

    belongs_to :location_equipment

    enum :kind, {service: 0, battery_change: 1, belt_change: 2, torque: 3, cleaning: 4, srt_900: 5, thermography: 6, electrical_approval: 7}
  end

  def up
    ServiceKind.ensure_legacy_kinds!

    LocationEquipment.find_each do |location_equipment|
      location_equipment.sync_location_equipment_services!
    end

    latest_service_dates.find_each do |service_date|
      location_equipment = service_date.location_equipment
      service_kind = ServiceKind.find_by!(legacy_key: service_date.kind)
      les = location_equipment.location_equipment_services.find_by!(service_kind: service_kind)

      next if ServiceOccurrence.pending.exists?(location_equipment_service_id: les.id)

      ServiceOccurrence.create!(
        location_equipment_service: les,
        status: :pending,
        due_on: service_date.date.to_date
      )
    end
  end

  def down
    ServiceOccurrence.delete_all
  end

  private

  def latest_service_dates
    ServiceDate.from(
      ServiceDate.select("DISTINCT ON (location_equipment_id, kind) service_dates.*")
        .order(:location_equipment_id, :kind, date: :desc),
      :service_dates
    )
  end
end
