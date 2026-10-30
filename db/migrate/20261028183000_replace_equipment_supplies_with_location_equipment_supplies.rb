class ReplaceEquipmentSuppliesWithLocationEquipmentSupplies < ActiveRecord::Migration[8.0]
  def up
    drop_table :equipment_supplies

    create_table :equipment_supplies do |t|
      t.references :location_equipment, null: false, foreign_key: true, index: false
      t.references :supply, null: false, foreign_key: true
      t.integer :quantity, null: false

      t.timestamps
    end

    add_index :equipment_supplies, [:location_equipment_id, :supply_id], unique: true,
      name: "index_equipment_supplies_on_location_equipment_and_supply"
  end

  def down
    drop_table :equipment_supplies

    create_table :equipment_supplies do |t|
      t.string :equipmentable_type, null: false
      t.bigint :equipmentable_id, null: false
      t.string :suppliable_type, null: false
      t.bigint :suppliable_id, null: false
      t.integer :quantity

      t.timestamps
    end

    add_index :equipment_supplies, [:equipmentable_type, :equipmentable_id],
      name: "index_equipment_supplies_on_equipmentable"
    add_index :equipment_supplies, [:suppliable_type, :suppliable_id],
      name: "index_equipment_supplies_on_suppliable"
  end
end
