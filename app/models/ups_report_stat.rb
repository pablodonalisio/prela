class UpsReportStat < ApplicationRecord
  OPERATING_MODE_OPTIONS = ["Normal", "Bypass", "En Batería", "Fuera de servicio", "Apagado", "Con alarma", "Sin acceso"]
  PAT_STATE_OPTIONS = ["Correcto", "Incorrecto", "No tiene"]
  VENTILATION_STATE_OPTIONS = ["Bien", "Mal", "No tiene"]
  ALARMS_PRESENCE_OPTIONS = ["Si", "No"]
  belongs_to :report

  validates :operating_mode, :associated_charge, :battery_charge, :pat_state, :ventilation_state, :alarms_presence, presence: true
  validates :voltage_input, :voltage_output, presence: true, if: :ups_monophase?
  validates :voltage_input_l1, :voltage_input_l2, :voltage_input_l3, :voltage_output_l1, :voltage_output_l2, :voltage_output_l3, presence: true, if: :ups_triphase?
  validates :battery_charge, :associated_charge, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100}, allow_nil: true
  validates :operating_mode, inclusion: {in: OPERATING_MODE_OPTIONS, message: "Debe ser alguno de los siguientes: #{OPERATING_MODE_OPTIONS.join(", ")}"}
  validates :pat_state, inclusion: {in: PAT_STATE_OPTIONS, message: "Debe ser alguno de los siguientes: #{PAT_STATE_OPTIONS.join(", ")}"}
  validates :ventilation_state, inclusion: {in: VENTILATION_STATE_OPTIONS, message: "Debe ser alguno de los siguientes: #{VENTILATION_STATE_OPTIONS.join(", ")}"}
  validates :alarms_presence, inclusion: {in: ALARMS_PRESENCE_OPTIONS, message: "Debe ser alguno de los siguientes: #{ALARMS_PRESENCE_OPTIONS.join(", ")}"}

  def ups_monophase?
    !ups_triphase?
  end

  def ups_triphase?
    report.location_equipment.equipment.is_triphase
  end
end
