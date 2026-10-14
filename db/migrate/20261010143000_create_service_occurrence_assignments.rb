class CreateServiceOccurrenceAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :service_occurrence_assignments do |t|
      t.references :service_occurrence, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :service_occurrence_assignments,
      [:service_occurrence_id, :user_id],
      unique: true,
      name: "index_service_occurrence_assignments_uniqueness"
  end
end
