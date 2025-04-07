class ChangeOperatingTimeToFloatInPowerUnitReportStats < ActiveRecord::Migration[7.1]
  def up
    change_column :power_unit_report_stats, :operating_time, :float
  end

  def down
    change_column :power_unit_report_stats, :operating_time, :integer
  end
end
