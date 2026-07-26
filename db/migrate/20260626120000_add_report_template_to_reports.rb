class AddReportTemplateToReports < ActiveRecord::Migration[8.0]
  def change
    add_reference :reports, :report_template, foreign_key: true
    add_column :reports, :field_values, :jsonb, null: false, default: {}
  end
end
