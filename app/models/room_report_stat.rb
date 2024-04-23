class RoomReportStat < ApplicationRecord
  ROOM_STATUS_OPTIONS = ["Correcto", "Incorrecto"]
  AIR_CONDITIONING_OPTIONS = ["Correcto", "Incorrecto", "Falta refrigeración"]
  belongs_to :report

  validates :room_status, :air_conditioning, presence: true
  validates :room_status, inclusion: {in: ROOM_STATUS_OPTIONS, message: "Debe ser alguno de los siguientes: #{ROOM_STATUS_OPTIONS.join(", ")}"}
  validates :air_conditioning, inclusion: {in: AIR_CONDITIONING_OPTIONS, message: "Debe ser alguno de los siguientes: #{AIR_CONDITIONING_OPTIONS.join(", ")}"}
end
