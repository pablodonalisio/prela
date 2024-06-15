class PowerUnitReportStat < ApplicationRecord
  belongs_to :report

  validates :equipment_power, :start_key_on_auto, :rpm, :frequency, :battery_charge_control, :tension_between_phases_a_b, :tension_between_phases_b_c,
    :tension_between_phases_c_a, :initial_temperature, :running_temperature, :number_of_starts, :operating_time, :failed_starts, :oil_pressure, :fuel_level,
    :coolant_level, :oil_level, :testing_time, presence: true
end
