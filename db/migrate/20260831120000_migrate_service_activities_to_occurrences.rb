class MigrateServiceActivitiesToOccurrences < ActiveRecord::Migration[8.0]
  SERVICE_ACTIVITY_KINDS = {
    "Service general" => :service,
    "Cambio batería" => :battery_change,
    "Cambio correas" => :belt_change,
    "Torqueo" => :torque,
    "Limpieza" => :cleaning,
    "SRT-900" => :srt_900,
    "Termografía" => :thermography,
    "Apto eléctrico" => :electrical_approval
  }.freeze

  def up
    ServiceKind.ensure_legacy_kinds!

    Activity.where(kind: SERVICE_ACTIVITY_KINDS.keys).find_each do |activity|
      legacy_key = SERVICE_ACTIVITY_KINDS[activity.kind]
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
