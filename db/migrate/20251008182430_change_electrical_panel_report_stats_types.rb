class ChangeElectricalPanelReportStatsTypes < ActiveRecord::Migration[8.0]
  def up
    change_column :electrical_panel_report_stats, :voltage_presence_lights_in_operation, :string
    change_column :electrical_panel_report_stats, :operational_atmospheric_discharger, :string
  end

  def down
    change_column :electrical_panel_report_stats, :voltage_presence_lights_in_operation, :boolean, using: "CASE WHEN voltage_presence_lights_in_operation = 'Funciona correctamente' THEN TRUE ELSE FALSE END"
    change_column :electrical_panel_report_stats, :operational_atmospheric_discharger, :boolean, using: "CASE WHEN operational_atmospheric_discharger = 'Funciona correctamente' THEN TRUE ELSE FALSE END"
  end
end
