class ReplaceReportTemplateJsonWithSections < ActiveRecord::Migration[8.0]
  def up
    delete_template_reports
    delete_report_templates

    remove_column :report_templates, :equipment_specifications
    remove_column :report_templates, :location_specifications
    remove_column :report_templates, :measurements
    remove_column :report_templates, :room_specifications
    remove_column :reports, :field_values

    add_column :reports, :template_based, :boolean, null: false, default: false
    add_index :reports, :template_based

    remove_foreign_key :reports, :report_templates
    add_foreign_key :reports, :report_templates, on_delete: :nullify

    create_table :section_kinds do |t|
      t.string :key, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :section_kinds, :key, unique: true

    create_table :sections do |t|
      t.references :report_template, foreign_key: true
      t.references :report, foreign_key: {on_delete: :cascade}
      t.string :title, null: false
      t.integer :position, null: false, default: 0
      t.references :section_kind, null: false, foreign_key: true

      t.timestamps
    end
    add_index :sections, [:report_template_id, :position]
    add_index :sections, [:report_id, :position]
    add_check_constraint :sections,
      "(report_template_id IS NOT NULL AND report_id IS NULL) OR (report_template_id IS NULL AND report_id IS NOT NULL)",
      name: "sections_exactly_one_owner"

    create_table :text_sections do |t|
      t.references :section, null: false, foreign_key: {on_delete: :cascade}, index: {unique: true}
      t.text :body

      t.timestamps
    end

    create_table :image_sections do |t|
      t.references :section, null: false, foreign_key: {on_delete: :cascade}, index: {unique: true}

      t.timestamps
    end

    create_table :table_sections do |t|
      t.references :section, null: false, foreign_key: {on_delete: :cascade}, index: {unique: true}
      t.integer :row_count, null: false
      t.integer :column_count, null: false

      t.timestamps
    end

    create_table :table_cells do |t|
      t.references :table_section, null: false, foreign_key: {on_delete: :cascade}
      t.integer :row_index, null: false
      t.integer :column_index, null: false
      t.string :value_type, null: false
      t.text :value
      t.boolean :for_metrics, null: false, default: false
      t.boolean :fixed, null: false, default: false

      t.timestamps
    end
    add_index :table_cells, [:table_section_id, :row_index, :column_index], unique: true, name: "index_table_cells_on_position"

    execute <<~SQL
      INSERT INTO section_kinds (key, name, created_at, updated_at) VALUES
        ('text', 'Texto', NOW(), NOW()),
        ('images', 'Imágenes', NOW(), NOW()),
        ('table', 'Tabla', NOW(), NOW())
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def delete_template_reports
    report_ids = select_values("SELECT id FROM reports WHERE report_template_id IS NOT NULL")
    return if report_ids.empty?

    id_list = report_ids.join(",")
    %w[
      report_tasks
      report_comments
      reports_signatures
      ups_report_stats
      power_unit_report_stats
      electrical_panel_report_stats
      room_report_stats
    ].each do |table|
      execute("DELETE FROM #{table} WHERE report_id IN (#{id_list})")
    end
    execute("DELETE FROM versions WHERE item_type = 'Report' AND item_id IN (#{id_list})")

    blob_ids = select_values(
      "SELECT blob_id FROM active_storage_attachments WHERE record_type = 'Report' AND record_id IN (#{id_list})"
    )
    execute("DELETE FROM active_storage_attachments WHERE record_type = 'Report' AND record_id IN (#{id_list})")
    delete_orphan_blobs(blob_ids)

    execute("DELETE FROM reports WHERE id IN (#{id_list})")
  end

  def delete_report_templates
    execute("DELETE FROM location_equipments_report_templates")
    execute("DELETE FROM report_template_tasks")
    execute("DELETE FROM report_templates")
  end

  def delete_orphan_blobs(blob_ids)
    return if blob_ids.empty?

    blob_list = blob_ids.join(",")
    execute(<<~SQL)
      DELETE FROM active_storage_variant_records
      WHERE blob_id IN (#{blob_list})
        AND NOT EXISTS (
          SELECT 1 FROM active_storage_attachments
          WHERE active_storage_attachments.blob_id = active_storage_variant_records.blob_id
        )
    SQL
    execute(<<~SQL)
      DELETE FROM active_storage_blobs
      WHERE id IN (#{blob_list})
        AND NOT EXISTS (
          SELECT 1 FROM active_storage_attachments
          WHERE active_storage_attachments.blob_id = active_storage_blobs.id
        )
    SQL
  end
end
