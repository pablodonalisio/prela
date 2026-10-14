class RemoveSystemKeyFromAssetTypes < ActiveRecord::Migration[8.0]
  def up
    return unless column_exists?(:asset_types, :system_key)

    if index_exists?(:asset_types, :system_key, name: "index_asset_types_on_system_key")
      remove_index :asset_types, name: "index_asset_types_on_system_key"
    end
    remove_column :asset_types, :system_key
  end

  def down
    add_column :asset_types, :system_key, :string
    add_index :asset_types, :system_key,
      unique: true,
      where: "system_key IS NOT NULL AND discarded_at IS NULL",
      name: "index_asset_types_on_system_key"
  end
end
