class CreateEquipmentKindsServiceKinds < ActiveRecord::Migration[8.0]
  def up
    create_table :equipment_kinds_service_kinds, id: false do |t|
      t.references :equipment_kind, null: false, foreign_key: true
      t.references :service_kind, null: false, foreign_key: true
    end

    add_index :equipment_kinds_service_kinds,
      [:equipment_kind_id, :service_kind_id],
      unique: true,
      name: "index_equipment_kinds_service_kinds_uniqueness"

    ServiceKind.ensure_legacy_kinds!
    seed_legacy_assignments!
  end

  def down
    drop_table :equipment_kinds_service_kinds
  end

  private

  def seed_legacy_assignments!
    ServiceKind::LEGACY_EQUIPMENT_ASSIGNMENTS.each do |legacy_kind, legacy_keys|
      equipment_kind = EquipmentKind.find_by(legacy_kind: legacy_kind)
      next if equipment_kind.nil?

      legacy_keys.each do |legacy_key|
        service_kind = ServiceKind.find_by(legacy_key: legacy_key)
        next if service_kind.nil?

        execute(
          ActiveRecord::Base.sanitize_sql_array([
            <<~SQL.squish,
              INSERT INTO equipment_kinds_service_kinds (equipment_kind_id, service_kind_id)
              SELECT ?, ?
              WHERE NOT EXISTS (
                SELECT 1
                FROM equipment_kinds_service_kinds
                WHERE equipment_kind_id = ?
                  AND service_kind_id = ?
              )
            SQL
            equipment_kind.id,
            service_kind.id,
            equipment_kind.id,
            service_kind.id
          ])
        )
      end
    end
  end
end
