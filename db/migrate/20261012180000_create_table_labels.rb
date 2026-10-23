class CreateTableLabels < ActiveRecord::Migration[8.0]
  def change
    create_table :table_labels do |t|
      t.references :table_section, null: false, foreign_key: {on_delete: :cascade}
      t.string :axis, null: false
      t.integer :position, null: false
      t.string :label, null: false, default: ""

      t.timestamps
    end

    add_index :table_labels, [:table_section_id, :axis, :position], unique: true, name: "index_table_labels_on_position"
  end
end
