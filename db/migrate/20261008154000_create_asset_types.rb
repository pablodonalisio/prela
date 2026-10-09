class CreateAssetTypes < ActiveRecord::Migration[8.0]
  def up
    create_table :asset_types do |t|
      t.string :name, null: false
      t.string :normalized_name, null: false
      t.string :system_key
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :asset_types, :discarded_at
    add_index :asset_types, :normalized_name,
      unique: true,
      where: "discarded_at IS NULL",
      name: "index_asset_types_on_normalized_name"
    add_index :asset_types, :system_key,
      unique: true,
      where: "system_key IS NOT NULL AND discarded_at IS NULL",
      name: "index_asset_types_on_system_key"

    now = Time.current
    execute <<-SQL.squish
      INSERT INTO asset_types (name, normalized_name, system_key, created_at, updated_at)
      VALUES ('UPS', 'ups', 'ups', #{connection.quote(now)}, #{connection.quote(now)})
    SQL

    add_reference :equipment_kinds, :asset_type, foreign_key: true, index: true
    execute <<-SQL.squish
      UPDATE equipment_kinds
      SET asset_type_id = (SELECT id FROM asset_types WHERE system_key = 'ups')
    SQL
    change_column_null :equipment_kinds, :asset_type_id, false
  end

  def down
    remove_reference :equipment_kinds, :asset_type, foreign_key: true
    drop_table :asset_types
  end
end
