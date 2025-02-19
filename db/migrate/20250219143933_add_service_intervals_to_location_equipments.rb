class AddServiceIntervalsToLocationEquipments < ActiveRecord::Migration[7.1]
  def change
    add_column :location_equipments, :service_interval, :integer, default: 1
    add_column :location_equipments, :battery_change_interval, :integer, default: 2
    add_column :location_equipments, :belt_change_interval, :integer, default: 5
  end
end
