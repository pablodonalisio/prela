class AddBuildingServicesToLocationEquipment < ActiveRecord::Migration[8.0]
  def change
    add_column :location_equipments, :srt_900_interval, :integer, default: 1
    add_column :location_equipments, :last_srt_900, :date
    add_column :location_equipments, :next_srt_900, :date
    add_column :location_equipments, :thermography_interval, :integer, default: 1
    add_column :location_equipments, :last_thermography, :date
    add_column :location_equipments, :next_thermography, :date
    add_column :location_equipments, :electrical_approval_interval, :integer, default: 1
    add_column :location_equipments, :last_electrical_approval, :date
    add_column :location_equipments, :next_electrical_approval, :date
  end
end
