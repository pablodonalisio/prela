class CreateServiceOccurrences < ActiveRecord::Migration[8.0]
  def change
    create_table :service_occurrences do |t|
      t.references :location_equipment_service, null: false, foreign_key: true
      t.date :due_on, null: false
      t.integer :status, null: false, default: 0
      t.date :completed_on

      t.timestamps
    end

    add_index :service_occurrences, :location_equipment_service_id,
      unique: true,
      where: "status = 0",
      name: "index_service_occurrences_one_pending_per_les"
  end
end
