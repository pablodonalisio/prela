class MigrateServiceActivitiesToOccurrences < ActiveRecord::Migration[8.0]
  def up
    ServiceKind.ensure_legacy_kinds!

    service_kinds = Activity::KINDS.except(Activity::OTHER)

    Activity.where(kind: service_kinds.keys).find_each do |activity|
      legacy_key = Activity::KINDS[activity.kind]
      location_equipment = activity.location_equipment
      les = location_equipment.location_equipment_services
        .joins(:service_kind)
        .find_by(service_kinds: {legacy_key: legacy_key.to_s})
      next if les.nil?

      completed_on = activity.date.to_date
      next if ServiceOccurrence.completed.exists?(
        location_equipment_service_id: les.id,
        completed_on: completed_on
      )

      occurrence = ServiceOccurrence.create!(
        location_equipment_service: les,
        status: :completed,
        completed_on: completed_on,
        due_on: completed_on
      )

      occurrence.document.attach(activity.document.blob) if activity.document.attached?
    end

    reconcile_pending_occurrences!
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def reconcile_pending_occurrences!
    LocationEquipmentService.joins(:service_kind).where(service_kinds: {recurring: true}).find_each do |les|
      pending = ServiceOccurrence.pending.find_by(location_equipment_service_id: les.id)
      next if pending.nil?

      latest_completed = ServiceOccurrence.completed
        .where(location_equipment_service_id: les.id)
        .order(completed_on: :desc)
        .first
      next if latest_completed.nil?

      expected_due_on = les.advance(latest_completed.completed_on)
      pending.update!(due_on: expected_due_on) if pending.due_on != expected_due_on
    end
  end
end
