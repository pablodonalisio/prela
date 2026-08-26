class CreateServiceKinds < ActiveRecord::Migration[8.0]
  def up
    create_table :service_kinds do |t|
      t.string :name, null: false
      t.string :normalized_name, null: false
      t.integer :default_interval, null: false, default: 1
      t.integer :interval_unit, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.string :legacy_key
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :service_kinds, :discarded_at
    add_index :service_kinds, :normalized_name, unique: true, where: "(discarded_at IS NULL)"
    add_index :service_kinds, :legacy_key, unique: true, where: "(legacy_key IS NOT NULL)"

    ServiceKind::LEGACY_KINDS.each { |attrs| seed_legacy_kind!(attrs) }
  end

  def down
    drop_table :service_kinds
  end

  private

  def seed_legacy_kind!(attrs)
    execute(
      ActiveRecord::Base.sanitize_sql_array([
        <<~SQL.squish,
          INSERT INTO service_kinds
            (name, normalized_name, default_interval, interval_unit, priority, legacy_key, created_at, updated_at)
          SELECT ?, ?, ?, 0, 1, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
          WHERE NOT EXISTS (
            SELECT 1 FROM service_kinds WHERE legacy_key = ?
          )
        SQL
        attrs[:name],
        normalize_name(attrs[:name]),
        attrs[:default_interval],
        attrs[:legacy_key],
        attrs[:legacy_key]
      ])
    )
  end

  def normalize_name(value)
    ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
  end
end
