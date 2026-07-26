class AddDiscardedAtToCatalogModels < ActiveRecord::Migration[7.2]
  def up
    add_column :clients, :discarded_at, :datetime
    add_index :clients, :discarded_at

    add_column :locations, :discarded_at, :datetime
    add_index :locations, :discarded_at

    add_column :equipment, :discarded_at, :datetime
    add_index :equipment, :discarded_at

    add_column :location_equipments, :discarded_at, :datetime
    add_index :location_equipments, :discarded_at

    add_column :equipment_kinds, :discarded_at, :datetime
    add_index :equipment_kinds, :discarded_at

    remove_index :equipment_kinds, name: "index_equipment_kinds_on_name"
    remove_index :equipment_kinds, name: "index_equipment_kinds_on_normalized_name"
    remove_index :equipment_kinds, name: "index_equipment_kinds_on_legacy_kind"

    add_index :equipment_kinds, :name, unique: true, where: "discarded_at IS NULL",
      name: "index_equipment_kinds_on_name"
    add_index :equipment_kinds, :normalized_name, unique: true, where: "discarded_at IS NULL",
      name: "index_equipment_kinds_on_normalized_name"
    add_index :equipment_kinds, :legacy_kind, unique: true,
      where: "legacy_kind IS NOT NULL AND discarded_at IS NULL",
      name: "index_equipment_kinds_on_legacy_kind"
  end

  def down
    remove_index :equipment_kinds, name: "index_equipment_kinds_on_name"
    remove_index :equipment_kinds, name: "index_equipment_kinds_on_normalized_name"
    remove_index :equipment_kinds, name: "index_equipment_kinds_on_legacy_kind"

    add_index :equipment_kinds, :name, unique: true, name: "index_equipment_kinds_on_name"
    add_index :equipment_kinds, :normalized_name, unique: true,
      name: "index_equipment_kinds_on_normalized_name"
    add_index :equipment_kinds, :legacy_kind, unique: true, where: "(legacy_kind IS NOT NULL)",
      name: "index_equipment_kinds_on_legacy_kind"

    remove_index :equipment_kinds, :discarded_at
    remove_column :equipment_kinds, :discarded_at

    remove_index :location_equipments, :discarded_at
    remove_column :location_equipments, :discarded_at

    remove_index :equipment, :discarded_at
    remove_column :equipment, :discarded_at

    remove_index :locations, :discarded_at
    remove_column :locations, :discarded_at

    remove_index :clients, :discarded_at
    remove_column :clients, :discarded_at
  end
end
