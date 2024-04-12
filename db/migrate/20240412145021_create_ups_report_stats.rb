class CreateUpsReportStats < ActiveRecord::Migration[7.1]
  def change
    create_table :ups_report_stats do |t|
      t.references :report, null: false, foreign_key: true
      t.string :operating_mode
      t.float :associated_charge
      t.float :battery_charge
      t.float :voltage_input
      t.float :voltage_output
      t.string :pat_state
      t.string :alarms_presence
      t.string :ventilation_state

      t.timestamps
    end
  end
end
