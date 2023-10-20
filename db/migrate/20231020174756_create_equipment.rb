class CreateEquipment < ActiveRecord::Migration[7.1]
  def change
    create_table :equipment do |t|
      t.string :kind, null: false
      t.string :brand
      t.string :model, null: false
      t.string :technical_model
      t.float :kva
      t.integer :battery_qty
      t.string :battery_type
      t.string :battery_info
      t.string :manual
      t.text :details
      t.string :serial_number

      t.timestamps
    end
  end
end
