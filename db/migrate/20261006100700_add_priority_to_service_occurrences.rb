class AddPriorityToServiceOccurrences < ActiveRecord::Migration[8.0]
  def up
    add_column :service_occurrences, :priority, :integer, null: false, default: 1

    execute <<~SQL.squish
      UPDATE service_occurrences
      SET priority = service_kinds.priority
      FROM location_equipment_services
      JOIN service_kinds ON service_kinds.id = location_equipment_services.service_kind_id
      WHERE service_occurrences.location_equipment_service_id = location_equipment_services.id
    SQL
  end

  def down
    remove_column :service_occurrences, :priority
  end
end
