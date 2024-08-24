class AddStatsToPowerUnitReportStats < ActiveRecord::Migration[7.1]
  def change
    add_column :power_unit_report_stats, :lamp_test, :string
    add_column :power_unit_report_stats, :belt_condition, :string
    add_column :power_unit_report_stats, :air_filter_condition, :string
    add_column :power_unit_report_stats, :anti_vibration_pad_condition, :string
    add_column :power_unit_report_stats, :liquids_leaks, :string
    add_column :power_unit_report_stats, :connections_condition_and_battery_fixation, :string
    add_column :power_unit_report_stats, :cable_and_electrical_connections, :string
  end
end
