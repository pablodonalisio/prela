class CreateLocationEquipmentServices < ActiveRecord::Migration[8.0]
  def up
    create_table :location_equipment_services do |t|
      t.references :location_equipment, null: false, foreign_key: true
      t.references :service_kind, null: false, foreign_key: true
      t.integer :interval, null: false, default: 1
      t.integer :interval_unit, null: false, default: 0

      t.timestamps
    end

    add_index :location_equipment_services,
      [:location_equipment_id, :service_kind_id],
      unique: true,
      name: "index_location_equipment_services_uniqueness"

    ServiceKind.ensure_legacy_kinds!
    ServiceKind.ensure_legacy_equipment_assignments!
    backfill_location_equipment_services!
  end

  def down
    drop_table :location_equipment_services
  end

  private

  def backfill_location_equipment_services!
    LocationEquipment.kept.includes(equipment: {equipment_kind: :service_kinds}).find_each do |location_equipment|
      equipment_kind = location_equipment.equipment&.equipment_kind
      next if equipment_kind.nil?

      equipment_kind.service_kinds.each do |service_kind|
        next if service_kind.discarded?

        attrs = interval_attrs_for(location_equipment, service_kind)
        execute(
          ActiveRecord::Base.sanitize_sql_array([
            <<~SQL.squish,
              INSERT INTO location_equipment_services
                (location_equipment_id, service_kind_id, interval, interval_unit, created_at, updated_at)
              SELECT ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
              WHERE NOT EXISTS (
                SELECT 1 FROM location_equipment_services
                WHERE location_equipment_id = ?
                  AND service_kind_id = ?
              )
            SQL
            location_equipment.id,
            service_kind.id,
            attrs[:interval],
            attrs[:interval_unit],
            location_equipment.id,
            service_kind.id
          ])
        )
      end
    end
  end

  def interval_attrs_for(location_equipment, service_kind)
    if service_kind.legacy_key.present? && location_equipment.respond_to?("#{service_kind.legacy_key}_interval")
      value = location_equipment.public_send("#{service_kind.legacy_key}_interval")
      {
        interval: value.presence || service_kind.default_interval,
        interval_unit: LocationEquipmentService.interval_units[:years]
      }
    else
      {
        interval: service_kind.default_interval,
        interval_unit: ServiceKind.interval_units[service_kind.interval_unit]
      }
    end
  end
end
