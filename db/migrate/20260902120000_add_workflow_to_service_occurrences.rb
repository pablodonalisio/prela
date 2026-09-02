class AddWorkflowToServiceOccurrences < ActiveRecord::Migration[8.0]
  def up
    add_column :service_occurrences, :planned_on, :date
    add_column :service_occurrences, :notes, :text

    remove_index :service_occurrences, name: "index_service_occurrences_one_pending_per_les"

    add_index :service_occurrences, :location_equipment_service_id,
      unique: true,
      where: "status IN (0, 2, 3)",
      name: "index_service_occurrences_one_open_per_les"
  end

  def down
    remove_index :service_occurrences, name: "index_service_occurrences_one_open_per_les"

    add_index :service_occurrences, :location_equipment_service_id,
      unique: true,
      where: "status = 0",
      name: "index_service_occurrences_one_pending_per_les"

    remove_column :service_occurrences, :notes
    remove_column :service_occurrences, :planned_on
  end
end
