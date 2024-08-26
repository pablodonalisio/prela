class AddBeltServiceDatesToLocationEquipments < ActiveRecord::Migration[7.1]
  def change
    add_column :location_equipments, :last_belt_change, :date
    add_column :location_equipments, :next_belt_change, :date
  end
end
