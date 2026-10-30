class AddDescriptionToSupplyKinds < ActiveRecord::Migration[8.0]
  def change
    add_column :supply_kinds, :description, :text
  end
end