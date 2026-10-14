class RenameAssetTypesToAssetsCategories < ActiveRecord::Migration[8.0]
  def change
    rename_table :asset_types, :assets_categories
    rename_column :equipment_kinds, :asset_type_id, :assets_category_id
  end
end
