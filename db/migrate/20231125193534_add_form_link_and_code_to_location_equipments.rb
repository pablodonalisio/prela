class AddFormLinkAndCodeToLocationEquipments < ActiveRecord::Migration[7.1]
  def change
    add_column :location_equipments, :form_link, :string
    add_column :location_equipments, :code, :string
  end
end
