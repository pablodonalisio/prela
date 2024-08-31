class AddTriphasicVoltagesToUpsReportStats < ActiveRecord::Migration[7.1]
  def change
    add_column :ups_report_stats, :voltage_input_l1, :float
    add_column :ups_report_stats, :voltage_input_l2, :float
    add_column :ups_report_stats, :voltage_input_l3, :float
    add_column :ups_report_stats, :voltage_output_l1, :float
    add_column :ups_report_stats, :voltage_output_l2, :float
    add_column :ups_report_stats, :voltage_output_l3, :float
  end
end
