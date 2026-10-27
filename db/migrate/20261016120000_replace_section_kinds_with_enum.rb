class ReplaceSectionKindsWithEnum < ActiveRecord::Migration[8.0]
  def up
    add_column :sections, :kind, :integer

    execute <<~SQL
      UPDATE sections
      SET kind = CASE section_kinds.key
        WHEN 'text' THEN 0
        WHEN 'images' THEN 1
        WHEN 'table' THEN 2
        WHEN 'list' THEN 3
      END
      FROM section_kinds
      WHERE sections.section_kind_id = section_kinds.id
    SQL

    change_column_null :sections, :kind, false
    change_column_default :sections, :kind, from: nil, to: 0

    remove_reference :sections, :section_kind, foreign_key: true, index: true
    drop_table :section_kinds
  end

  def down
    create_table :section_kinds do |t|
      t.string :key, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :section_kinds, :key, unique: true

    execute <<~SQL
      INSERT INTO section_kinds (key, name, created_at, updated_at) VALUES
        ('text', 'Texto', NOW(), NOW()),
        ('images', 'Imágenes', NOW(), NOW()),
        ('table', 'Tabla', NOW(), NOW()),
        ('list', 'Listado', NOW(), NOW())
    SQL

    add_reference :sections, :section_kind, foreign_key: true

    execute <<~SQL
      UPDATE sections
      SET section_kind_id = section_kinds.id
      FROM section_kinds
      WHERE section_kinds.key = CASE sections.kind
        WHEN 0 THEN 'text'
        WHEN 1 THEN 'images'
        WHEN 2 THEN 'table'
        WHEN 3 THEN 'list'
      END
    SQL

    change_column_null :sections, :section_kind_id, false
    remove_column :sections, :kind
  end
end
