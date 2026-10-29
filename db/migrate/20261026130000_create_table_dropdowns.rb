class CreateTableDropdowns < ActiveRecord::Migration[8.0]
  def change
    create_table :table_dropdowns do |t|
      t.string :name, null: false
      t.string :normalized_name, null: false
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :table_dropdowns, :discarded_at
    add_index :table_dropdowns, :normalized_name, unique: true, where: "(discarded_at IS NULL)"

    create_table :table_dropdown_values do |t|
      t.references :table_dropdown, null: false, foreign_key: {on_delete: :cascade}
      t.string :label, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :table_dropdown_values, [:table_dropdown_id, :position]

    add_reference :table_cells, :table_dropdown, foreign_key: {on_delete: :restrict}
  end
end
