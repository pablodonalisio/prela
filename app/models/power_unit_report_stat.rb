class PowerUnitReportStat < ApplicationRecord
  GENERAL_DISCONNECTOR_OPTIONS = ["ON", "OFF"]
  EMERGENCY_STOP_POSITION_OPTIONS = ["ON", "OFF"]
  START_KEY_ON_AUTO_OPTIONS = ["Auto", "Manual"]
  LAMP_TEST_OPTIONS = ["Bien", "Mal"]
  BELT_CONDITION_OPTIONS = ["Sobretensada", "Bien", "Floja", "Reemplazar"]
  AIR_FILTER_CONDITION_OPTIONS = ["Bien", "Reemplazar"]
  ANTI_VIBRATION_PAD_CONDITION_OPTIONS = ["Bien", "Reemplazar", "No posee"]
  LIQUIDS_LEAKS_OPTIONS = ["Si", "No"]
  CONNECTIONS_CONDITION_AND_BATTERY_FIXATION_OPTIONS = ["OK", "Mal"]
  CABLE_AND_ELECTRICAL_CONNECTIONS_CONDITION_OPTIONS = ["OK", "Mal"]
  OIL_PRESSURE_UNIT_OPTIONS = ["kPa", "psi", "bar"]
  COOLANT_LEVEL_OPTIONS = ["Bajo", "Medio", "Full"]
  OIL_LEVEL_OPTIONS = ["Bajo", "Medio", "Full"]

  belongs_to :report

  validates :start_key_on_auto, :rpm, :frequency, :battery_charge_control, :tension_between_phases_a_b, :tension_between_phases_b_c,
    :tension_between_phases_c_a, :initial_temperature, :running_temperature, :number_of_starts, :operating_time, :failed_starts, :oil_pressure, :fuel_level,
    :coolant_level, :oil_level, :testing_time, :lamp_test, :belt_condition, :air_filter_condition, :anti_vibration_pad_condition, :liquids_leaks,
    :connections_condition_and_battery_fixation, :cable_and_electrical_connections, :general_disconnector,
    :emergency_stop_position, :oil_pressure_unit, presence: true

  validates :general_disconnector, inclusion: {in: GENERAL_DISCONNECTOR_OPTIONS}
  validates :emergency_stop_position, inclusion: {in: EMERGENCY_STOP_POSITION_OPTIONS}
  validates :start_key_on_auto, inclusion: {in: START_KEY_ON_AUTO_OPTIONS}
  validates :oil_pressure_unit, inclusion: {in: OIL_PRESSURE_UNIT_OPTIONS}
  validates :coolant_level, inclusion: {in: COOLANT_LEVEL_OPTIONS}
end
