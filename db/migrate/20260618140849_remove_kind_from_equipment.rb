class RemoveKindFromEquipment < ActiveRecord::Migration[8.0]
  def change
    remove_column :equipment, :kind, :integer
  end
end
