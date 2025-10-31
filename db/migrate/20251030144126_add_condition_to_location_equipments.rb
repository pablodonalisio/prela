class AddConditionToLocationEquipments < ActiveRecord::Migration[8.0]
  def change
    add_column :location_equipments, :condition, :string, default: "Buena"
  end
end
