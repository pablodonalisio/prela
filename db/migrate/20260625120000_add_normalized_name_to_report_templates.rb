class AddNormalizedNameToReportTemplates < ActiveRecord::Migration[8.0]
  class MigrationReportTemplate < ApplicationRecord
    self.table_name = "report_templates"
  end

  def up
    add_column :report_templates, :normalized_name, :string
    backfill_normalized_names
    add_index :report_templates, :normalized_name, unique: true
  end

  def down
    remove_index :report_templates, :normalized_name
    remove_column :report_templates, :normalized_name
  end

  private

  def backfill_normalized_names
    MigrationReportTemplate.find_each do |report_template|
      report_template.update_column(:normalized_name, normalize_name(report_template.name))
    end
  end

  def normalize_name(value)
    ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
  end
end
