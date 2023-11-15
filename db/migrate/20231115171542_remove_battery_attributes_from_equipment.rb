class RemoveBatteryAttributesFromEquipment < ActiveRecord::Migration[7.1]
  def change
    remove_column :equipment, :battery_type
    remove_column :equipment, :battery_qty
    remove_column :equipment, :battery_info
  end
end
