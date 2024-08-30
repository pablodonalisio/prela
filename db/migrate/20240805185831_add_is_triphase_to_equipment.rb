class AddIsTriphaseToEquipment < ActiveRecord::Migration[7.1]
  def change
    add_column :equipment, :is_triphase, :boolean
  end
end
