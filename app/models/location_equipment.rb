class LocationEquipment < ApplicationRecord
  include Filterable

  ACTIVITY_KIND = {
    last_battery_change: Activity::BATTERY_CHANGE,
    last_service: Activity::SERVICE,
    last_belt_change: Activity::BELT_CHANGE
  }

  SERVICE_KINDS = {
    "ups" => %i[battery_change],
    "power_unit" => %i[service battery_change belt_change]
  }

  after_create :create_next_service_dates

  belongs_to :location
  belongs_to :equipment
  has_many :equipment_supplies, dependent: :destroy, as: :equipmentable
  has_one :equipment_battery, dependent: :destroy, as: :equipmentable, class_name: "EquipmentSupply"
  has_one :battery, through: :equipment_battery, source: :suppliable, source_type: "Battery"
  has_many :reports, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :service_dates, dependent: :destroy

  scope :by_client_ids, ->(client_id) { joins(:location).where(location: {client_id:}) }
  scope :by_location_ids, ->(location_id) { where(location_id:) }
  scope :by_status, ->(status) { where(status:) }
  scope :by_kind, ->(kind) { joins(:equipment).where(equipment: {kind:}) }
  scope :ups_with_overdue_maintenance, -> { by_kind(:ups).where("next_battery_change < ?", Date.current) }
  scope :power_units_with_overdue_maintenance, -> { by_kind(:power_unit).where("next_service < ? OR next_battery_change < ? OR next_belt_change < ?", Date.current, Date.current, Date.current) }

  enum status: {active: 0, out_of_service: 1, prela_to_check: 2, prela_to_deliver: 3, prela_on_service: 4, inaccessible: 5}

  delegate :avatar, :model, :kind, to: :equipment
  delegate :client, to: :location

  def next_service_dates
    service_dates.select("DISTINCT ON (kind) *").order(:kind, date: :desc)
  end

  def last_service_date(service_kind)
    activities.where(kind: ACTIVITY_KIND[service_kind]).order(date: :desc).first&.date&.to_date || send(service_kind) # send(service_kind) is for legacy behaviour
  end

  def create_next_service_dates(from_date = Time.current, kinds = SERVICE_KINDS[kind])
    kinds.each do |kind|
      next_date = from_date + send("#{kind}_interval").years
      service_dates.create(kind: kind, date: next_date)
    end
  end

  def calculate_next_service_date(service_kind, from_date = Time.current)
    from_date + send("#{service_kind}_interval").years
  end
end
