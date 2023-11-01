class RemoveSerialNumberFromEquipment < ActiveRecord::Migration[7.1]
  def change
    remove_column :equipment, :serial_number, :string
  end
end
