class RoomReportStat < ApplicationRecord
  ROOM_STATUS_OPTIONS = ["Correcto", "Incorrecto"]
  AIR_CONDITIONING_OPTIONS = ["Correcto", "Incorrecto", "Falta refrigeración", "Sala sin aire"]
  belongs_to :report

  validates :room_status, presence: true, if: :power_unit?
  validates :room_status, :air_conditioning, :temperature, :humidity, presence: true, if: :ups?
  validates :clean_and_tidy, :ventilated, :free_access_to_panel, :with_access_key, presence: true, if: :electrical_panel?

  def self.permitted_attributes
    %i[
      room_status
      air_conditioning
      temperature
      humidity
      clean_and_tidy
      ventilated
      free_access_to_panel
      with_access_key
    ]
  end

  private

  def power_unit?
    report.location_equipment.equipment.power_unit?
  end

  def ups?
    report.location_equipment.equipment.ups?
  end

  def electrical_panel?
    report.location_equipment.equipment.electrical_panel?
  end
end
