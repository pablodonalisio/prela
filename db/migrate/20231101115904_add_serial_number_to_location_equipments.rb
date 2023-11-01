class AddSerialNumberToLocationEquipments < ActiveRecord::Migration[7.1]
  def change
    add_column :location_equipments, :serial_number, :string
  end
end
