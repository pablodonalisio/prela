class UpsReportStat < ApplicationRecord
  OPERATING_MODE_OPTIONS = ["Normal", "Bypass", "En Batería", "Fuera de servicio", "Apagado"]
  PAT_STATE_OPTIONS = ["Correcto", "Incorrecto", "No tiene"]
  VENTILATION_STATE_OPTIONS = ["Bien", "Mal", "No tiene"]
  ALARMS_PRESENCE_OPTIONS = ["Si", "No"]
  belongs_to :report

  validates :operating_mode, :associated_charge, :battery_charge, :voltage_input, :voltage_output, :pat_state, :ventilation_state, :alarms_presence, presence: true
  validates :battery_charge, :associated_charge, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100}, allow_nil: true
  validates :operating_mode, inclusion: {in: OPERATING_MODE_OPTIONS, message: "Debe ser alguno de los siguientes: #{OPERATING_MODE_OPTIONS.join(", ")}"}
  validates :pat_state, inclusion: {in: PAT_STATE_OPTIONS, message: "Debe ser alguno de los siguientes: #{PAT_STATE_OPTIONS.join(", ")}"}
  validates :ventilation_state, inclusion: {in: VENTILATION_STATE_OPTIONS, message: "Debe ser alguno de los siguientes: #{VENTILATION_STATE_OPTIONS.join(", ")}"}
  validates :alarms_presence, inclusion: {in: ALARMS_PRESENCE_OPTIONS, message: "Debe ser alguno de los siguientes: #{ALARMS_PRESENCE_OPTIONS.join(", ")}"}
end
