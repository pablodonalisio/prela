class CreateEquipmentKinds < ActiveRecord::Migration[8.0]
  def change
    create_table :equipment_kinds do |t|
      t.string :name
      t.jsonb :fields, null: false, default: {}

      t.timestamps
    end

    add_column :equipment, :equipment_kind_id, :integer
  end
end
