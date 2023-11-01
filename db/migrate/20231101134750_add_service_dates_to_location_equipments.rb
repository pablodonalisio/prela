class AddServiceDatesToLocationEquipments < ActiveRecord::Migration[7.1]
  def change
    add_column :location_equipments, :last_service, :date
    add_column :location_equipments, :next_service, :date
    add_column :location_equipments, :last_battery_change, :date
    add_column :location_equipments, :next_battery_change, :date
  end
end
