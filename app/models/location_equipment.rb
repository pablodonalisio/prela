class LocationEquipment < ApplicationRecord
  include Filterable

  ACTIVITY_KIND = {
    last_battery_change: Activity::BATTERY_CHANGE,
    last_service: Activity::SERVICE,
    last_belt_change: Activity::BELT_CHANGE,
    last_torque: Activity::TORQUE,
    last_cleaning: Activity::CLEANING
  }

  SERVICE_KINDS = {
    "ups" => %i[battery_change],
    "power_unit" => %i[service battery_change belt_change],
    "electrical_panel" => %i[service torque cleaning]
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
  has_many :documents, as: :documentable, dependent: :destroy

  scope :by_client_ids, ->(client_id) { joins(:location).where(location: {client_id:}) }
  scope :by_location_ids, ->(location_id) { where(location_id:) }
  scope :by_status, ->(status) { where(status:) }
  scope :by_kind, ->(kind) { joins(:equipment).where(equipment: {kind:}) }

  enum :status, {active: 0, out_of_service: 1, prela_to_check: 2, prela_to_deliver: 3, prela_on_service: 4, inaccessible: 5}

  delegate :avatar, :model, :kind, to: :equipment
  delegate :client, to: :location

  validates :location_id, :equipment_id, presence: true

  class << self
    def with_overdue_maintenance(equipment_kind)
      by_kind(equipment_kind)
        .where(id: overdue_equipment_ids)
    end

    private

    def overdue_equipment_ids
      ServiceDate.select(:location_equipment_id)
        .group(:location_equipment_id, :kind)
        .having("MAX(service_dates.date) < ?", 3.months.from_now)
        .map(&:location_equipment_id)
    end
  end

  def next_service_dates
    service_dates.select("DISTINCT ON (kind) *").order(:kind, date: :desc)
  end

  def last_service_date(service_kind)
    raise "Undefined activity kind" unless ACTIVITY_KIND.key?(service_kind)

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
