class AddElecticalPanelServicesToLocationEquipment < ActiveRecord::Migration[8.0]
  def change
    add_column :location_equipments, :torque_interval, :integer, default: 1
    add_column :location_equipments, :last_torque, :date
    add_column :location_equipments, :next_torque, :date
    add_column :location_equipments, :cleaning_interval, :integer, default: 1
    add_column :location_equipments, :last_cleaning, :date
    add_column :location_equipments, :next_cleaning, :date
  end
end
