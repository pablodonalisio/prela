class AddSerialNumbersToPowerUnitEquipment < ActiveRecord::Migration[7.1]
  def change
    add_column :location_equipments, :engine_serial_number, :string
    add_column :location_equipments, :power_unit_serial_number, :string
  end
end
