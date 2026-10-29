class AddRemovedAtToLocationEquipmentServices < ActiveRecord::Migration[8.0]
  def change
    add_column :location_equipment_services, :removed_at, :datetime
    add_index :location_equipment_services, :removed_at
  end
end
