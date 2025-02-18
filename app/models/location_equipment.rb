class LocationEquipment < ApplicationRecord
  include Filterable

  belongs_to :location
  belongs_to :equipment
  has_many :equipment_supplies, dependent: :destroy, as: :equipmentable
  has_one :equipment_battery, dependent: :destroy, as: :equipmentable, class_name: "EquipmentSupply"
  has_one :battery, through: :equipment_battery, source: :suppliable, source_type: "Battery"
  has_many :reports, dependent: :destroy
  has_many :activities, dependent: :destroy

  scope :by_client_ids, ->(client_id) { joins(:location).where(location: {client_id:}) }
  scope :by_location_ids, ->(location_id) { where(location_id:) }
  scope :by_status, ->(status) { where(status:) }
  scope :by_kind, ->(kind) { joins(:equipment).where(equipment: {kind:}) }
  scope :ups_with_overdue_maintenance, -> { by_kind(:ups).where("next_battery_change < ?", Date.current) }
  scope :power_units_with_overdue_maintenance, -> { by_kind(:power_unit).where("next_service < ? OR next_battery_change < ? OR next_belt_change < ?", Date.current, Date.current, Date.current) }

  enum status: {active: 0, out_of_service: 1, prela_to_check: 2, prela_to_deliver: 3, prela_on_service: 4, inaccessible: 5}

  delegate :avatar, :model, to: :equipment
  delegate :client, to: :location

  def service_dates
    if equipment.kind.eql?("ups")
      %i[last_battery_change next_battery_change]
    elsif equipment.kind.eql?("power_unit")
      %i[last_service next_service last_battery_change next_battery_change last_belt_change next_belt_change]
    else
      raise "No estan definidas las fechas de servicio para el equipo #{equipment.kind}"
    end
  end
end
