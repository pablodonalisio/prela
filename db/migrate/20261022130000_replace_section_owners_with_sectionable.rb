class ReplaceSectionOwnersWithSectionable < ActiveRecord::Migration[8.0]
  def up
    add_column :sections, :sectionable_type, :string
    add_column :sections, :sectionable_id, :bigint

    execute <<~SQL.squish
      UPDATE sections
      SET sectionable_type = 'ReportTemplate', sectionable_id = report_template_id
      WHERE report_template_id IS NOT NULL
    SQL

    execute <<~SQL.squish
      UPDATE sections
      SET sectionable_type = 'Report', sectionable_id = report_id
      WHERE report_id IS NOT NULL
    SQL

    change_column_null :sections, :sectionable_type, false
    change_column_null :sections, :sectionable_id, false

    add_index :sections, [:sectionable_type, :sectionable_id, :position],
      name: "index_sections_on_sectionable_and_position"

    add_check_constraint :sections,
      "sectionable_type IN ('Report', 'ReportTemplate')",
      name: "sections_sectionable_type"

    remove_check_constraint :sections, name: "sections_exactly_one_owner"
    remove_foreign_key :sections, :report_templates
    remove_foreign_key :sections, :reports
    remove_column :sections, :report_template_id, :bigint
    remove_column :sections, :report_id, :bigint
  end

  def down
    add_reference :sections, :report_template, foreign_key: true, index: false
    add_reference :sections, :report, foreign_key: {on_delete: :cascade}, index: false

    execute <<~SQL.squish
      UPDATE sections
      SET report_template_id = sectionable_id
      WHERE sectionable_type = 'ReportTemplate'
    SQL

    execute <<~SQL.squish
      UPDATE sections
      SET report_id = sectionable_id
      WHERE sectionable_type = 'Report'
    SQL

    add_index :sections, :report_template_id
    add_index :sections, [:report_template_id, :position]
    add_index :sections, :report_id
    add_index :sections, [:report_id, :position]

    add_check_constraint :sections,
      "(report_template_id IS NOT NULL AND report_id IS NULL) OR (report_template_id IS NULL AND report_id IS NOT NULL)",
      name: "sections_exactly_one_owner"

    remove_check_constraint :sections, name: "sections_sectionable_type"
    remove_index :sections, name: "index_sections_on_sectionable_and_position"
    remove_column :sections, :sectionable_type, :string
    remove_column :sections, :sectionable_id, :bigint
  end
end
