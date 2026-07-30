class AddDistanceAboveToContacts < ActiveRecord::Migration[7.2]
  def change
    add_column :contacts, :distance_above, :integer, null: false, default: 0
  end
end
