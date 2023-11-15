class CreateEquipmentSupplies < ActiveRecord::Migration[7.1]
  def change
    create_table :equipment_supplies do |t|
      t.references :equipmentable, null: false, polymorphic: true
      t.references :suppliable, null: false, polymorphic: true
      t.integer :quantity

      t.timestamps
    end
  end
end
