class CreateLocationEquipments < ActiveRecord::Migration[7.1]
  def change
    create_table :location_equipments do |t|
      t.string :zone
      t.integer :floor
      t.references :location, null: false, foreign_key: true
      t.references :equipment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
