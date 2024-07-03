class AddPowerUnitAttributesToEquipment < ActiveRecord::Migration[7.1]
  def change
    add_column :equipment, :motor_brand, :string
    add_column :equipment, :motor_model, :string
    add_column :equipment, :generator_brand, :string
    add_column :equipment, :generator_model, :string
    add_column :equipment, :kw, :integer
  end
end
