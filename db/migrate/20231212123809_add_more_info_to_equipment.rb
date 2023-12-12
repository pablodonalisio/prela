class AddMoreInfoToEquipment < ActiveRecord::Migration[7.1]
  def change
    add_column :equipment, :more_info, :text
  end
end
