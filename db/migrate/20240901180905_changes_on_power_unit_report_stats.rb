class ChangesOnPowerUnitReportStats < ActiveRecord::Migration[7.1]
  def up
    remove_column :power_unit_report_stats, :equipment_power, :string
    change_column :power_unit_report_stats, :general_disconnector, :string
    change_column :power_unit_report_stats, :emergency_stop_position, :string
    change_column :power_unit_report_stats, :fuel_level, :string
    change_column :power_unit_report_stats, :coolant_level, :string
    change_column :power_unit_report_stats, :oil_level, :string
    add_column :power_unit_report_stats, :oil_pressure_unit, :string
  end

  def down
    add_column :power_unit_report_stats, :equipment_power, :string
    change_column :power_unit_report_stats, :general_disconnector, :boolean, using: "general_disconnector::boolean"
    change_column :power_unit_report_stats, :emergency_stop_position, :boolean, using: "emergency_stop_position::boolean"
    change_column :power_unit_report_stats, :fuel_level, :string
    change_column :power_unit_report_stats, :coolant_level, :string
    change_column :power_unit_report_stats, :oil_level, :string
    remove_column :power_unit_report_stats, :oil_pressure_unit, :string
  end
end
