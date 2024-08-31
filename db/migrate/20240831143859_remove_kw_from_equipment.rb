class RemoveKwFromEquipment < ActiveRecord::Migration[7.1]
  def up
    change_kw_for_kva
    remove_column :equipment, :kw, :integer
  end

  def down
    add_column :equipment, :kw, :integer
  end

  private

  def change_kw_for_kva
    Equipment.power_unit.where.not(kw: nil).each do |equipment|
      equipment.update(kva: equipment.kw)
    end
  end
end
