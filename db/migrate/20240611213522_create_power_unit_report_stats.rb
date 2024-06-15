class CreatePowerUnitReportStats < ActiveRecord::Migration[7.1]
  def change
    create_table :power_unit_report_stats do |t|
      t.references :report, null: false, foreign_key: true
      t.string :equipment_power
      t.boolean :general_disconnector
      t.boolean :emergency_stop_position
      t.string :start_key_on_auto
      t.integer :rpm
      t.float :frequency
      t.float :battery_charge_control
      t.integer :tension_between_phases_a_b
      t.integer :tension_between_phases_b_c
      t.integer :tension_between_phases_c_a
      t.float :initial_temperature
      t.float :running_temperature
      t.integer :number_of_starts
      t.integer :operating_time
      t.integer :failed_starts
      t.float :oil_pressure
      t.integer :fuel_level
      t.integer :coolant_level
      t.integer :oil_level
      t.integer :testing_time

      t.timestamps
    end
  end
end
