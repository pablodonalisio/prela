class AddListSections < ActiveRecord::Migration[8.0]
  def change
    create_table :list_sections do |t|
      t.references :section, null: false, foreign_key: {on_delete: :cascade}, index: {unique: true}

      t.timestamps
    end

    create_table :list_items do |t|
      t.references :list_section, null: false, foreign_key: {on_delete: :cascade}
      t.string :name, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :list_items, [:list_section_id, :position]

    execute <<~SQL
      INSERT INTO section_kinds (key, name, created_at, updated_at)
      VALUES ('list', 'Listado', NOW(), NOW())
      ON CONFLICT (key) DO UPDATE SET name = EXCLUDED.name, updated_at = NOW()
    SQL

    drop_table :report_tasks
    drop_table :report_template_tasks
  end
end
