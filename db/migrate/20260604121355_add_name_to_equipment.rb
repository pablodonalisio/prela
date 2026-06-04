class AddNameToEquipment < ActiveRecord::Migration[8.0]
  def up
    add_column :equipment, :name, :string

    Equipment.find_each do |equipment|
      name = equipment.brand.present? ? "#{equipment.brand} - #{equipment.model}" : equipment.model
      equipment.update_column(:name, name)
    end

    change_column_null :equipment, :name, false
    change_column_null :equipment, :model, true
  end

  def down
    Equipment.find_each do |equipment|
      equipment.update_column(:model, equipment.name) if equipment.model.blank?
    end

    change_column_null :equipment, :model, false
    remove_column :equipment, :name
  end
end
