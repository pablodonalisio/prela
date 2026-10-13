class CreateTableCellOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :table_cell_options do |t|
      t.references :table_cell, null: false, foreign_key: {on_delete: :cascade}
      t.boolean :value, null: false
      t.string :label, null: false, default: ""

      t.timestamps
    end

    add_index :table_cell_options, [:table_cell_id, :value], unique: true, name: "index_table_cell_options_on_value"
  end
end
