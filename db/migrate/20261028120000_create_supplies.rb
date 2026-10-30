class CreateSupplies < ActiveRecord::Migration[8.0]
  def change
    create_table :supply_kinds do |t|
      t.string :name, null: false
      t.string :normalized_name, null: false
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :supply_kinds, :discarded_at
    add_index :supply_kinds, :normalized_name, unique: true, where: "(discarded_at IS NULL)"

    create_table :supplies do |t|
      t.references :supply_kind, null: false, foreign_key: true
      t.string :name, null: false
      t.string :normalized_name, null: false
      t.text :description
      t.string :reference_url
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :supplies, :discarded_at
    add_index :supplies, :normalized_name, unique: true, where: "(discarded_at IS NULL)"

    create_table :supply_replacements do |t|
      t.references :supply, null: false, foreign_key: true
      t.references :replacement, null: false, foreign_key: {to_table: :supplies}
      t.check_constraint "supply_id < replacement_id", name: "supply_replacements_ordered_pair"

      t.timestamps
    end

    add_index :supply_replacements, [:supply_id, :replacement_id], unique: true,
      name: "index_supply_replacements_on_pair"
  end
end
