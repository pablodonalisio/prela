class ChangeKindToIntegerInEquipment < ActiveRecord::Migration[7.1]
  def up
    Equipment.update_all(kind: "0")
    change_column :equipment, :kind, :integer, using: "kind::integer"
  end

  def down
    change_column :equipment, :kind, :string
    Equipment.update_all(kind: "UPS")
  end
end
