class AddStatusToLocationEquipments < ActiveRecord::Migration[7.1]
  def change
    add_column :location_equipments, :status, :integer, default: 0
  end
end
