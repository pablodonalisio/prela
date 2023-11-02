class MoveDetailsToLocationEquipments < ActiveRecord::Migration[7.1]
  def change
    add_column :location_equipments, :details, :text
    remove_column :equipment, :details
  end
end
