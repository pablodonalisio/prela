class RemoveKindFromEquipment < ActiveRecord::Migration[8.0]
  def up
    remove_column :equipment, :kind, :integer
    # Dropping a column invalidates prepared statements that selected equipment.*.
    ActiveRecord::Base.connection.clear_cache!
  end

  def down
    add_column :equipment, :kind, :integer
    ActiveRecord::Base.connection.clear_cache!
  end
end
