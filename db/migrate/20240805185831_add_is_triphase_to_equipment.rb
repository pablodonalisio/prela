class AddIsTriphaseToEquipment < ActiveRecord::Migration[7.1]
  def change
    add_column :equipment, :is_triphase, :boolean, default: false
    end

  def data
    Equipment.update_all(is_triphase: false)
  end
end
