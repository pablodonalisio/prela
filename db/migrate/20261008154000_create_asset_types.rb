class CreateAssetTypes < ActiveRecord::Migration[8.0]
  def up
    create_table :asset_types do |t|
      t.string :name, null: false
      t.string :normalized_name, null: false
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :asset_types, :discarded_at
    add_index :asset_types, :normalized_name,
      unique: true,
      where: "discarded_at IS NULL",
      name: "index_asset_types_on_normalized_name"

    now = Time.current
    execute <<-SQL.squish
      INSERT INTO asset_types (name, normalized_name, created_at, updated_at)
      SELECT equipment_kinds.name, equipment_kinds.normalized_name, #{connection.quote(now)}, #{connection.quote(now)}
      FROM equipment_kinds
      WHERE equipment_kinds.normalized_name IS NOT NULL
      GROUP BY equipment_kinds.name, equipment_kinds.normalized_name
    SQL

    add_reference :equipment_kinds, :asset_type, foreign_key: true, index: true
    execute <<-SQL.squish
      UPDATE equipment_kinds
      SET asset_type_id = asset_types.id
      FROM asset_types
      WHERE asset_types.normalized_name = equipment_kinds.normalized_name
    SQL
    change_column_null :equipment_kinds, :asset_type_id, false
  end

  def down
    remove_reference :equipment_kinds, :asset_type, foreign_key: true
    drop_table :asset_types
  end
end
