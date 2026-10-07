class AddLayoutToReportTemplates < ActiveRecord::Migration[8.0]
  def up
    add_column :report_templates, :layout, :jsonb, null: false, default: []
    add_column :reports, :observation_values, :jsonb, null: false, default: {}

    default_layout = [
      {"id" => "measurements", "type" => "measurements"},
      {"id" => "room_specifications", "type" => "room_specifications"},
      {"id" => "tasks", "type" => "tasks"},
      {"id" => "images-default", "type" => "images"}
    ]

    execute <<~SQL.squish
      UPDATE report_templates
      SET layout = '#{default_layout.to_json}'::jsonb
    SQL
  end

  def down
    remove_column :reports, :observation_values
    remove_column :report_templates, :layout
  end
end
