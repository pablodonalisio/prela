class LocationEquipment < ApplicationRecord
  include Filterable

  ACTIVITY_KIND = {
    last_battery_change: Activity::BATTERY_CHANGE,
    last_service: Activity::SERVICE,
    last_belt_change: Activity::BELT_CHANGE,
    last_torque: Activity::TORQUE,
    last_cleaning: Activity::CLEANING,
    last_srt_900: Activity::SRT_900,
    last_thermography: Activity::THERMOGRAPHY,
    last_electrical_approval: Activity::ELECTRICAL_APPROVAL
  }

  SERVICE_KINDS = {
    "ups" => %i[battery_change],
    "power_unit" => %i[service battery_change belt_change],
    "electrical_panel" => %i[service torque cleaning],
    "building" => %i[srt_900 thermography electrical_approval]
  }

  CONDITIONS = {
    "Buena" => {color: "success"},
    "Aceptable" => {color: "warning"},
    "Deficiente" => {color: "danger"}
  }

  after_create :create_next_service_dates

  belongs_to :location
  belongs_to :equipment
  has_many :equipment_supplies, dependent: :destroy, as: :equipmentable
  has_one :equipment_battery, dependent: :destroy, as: :equipmentable, class_name: "EquipmentSupply"
  has_one :battery, through: :equipment_battery, source: :suppliable, source_type: "Battery"
  has_and_belongs_to_many :report_templates
  has_many :reports, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :service_dates, dependent: :destroy
  has_many :documents, as: :documentable, dependent: :destroy
  has_many :failures, dependent: :destroy

  scope :by_client_ids, ->(client_id) { joins(:location).where(location: {client_id:}) }
  scope :by_location_ids, ->(location_id) { where(location_id:) }
  scope :by_status, ->(status) { where(status:) }
  scope :by_equipment_kind_ids, ->(equipment_kind_ids) { joins(:equipment).where(equipment: {equipment_kind_id: equipment_kind_ids}) }

  enum :status, {active: 0, out_of_service: 1, prela_to_check: 2, prela_to_deliver: 3, prela_on_service: 4, inaccessible: 5}

  delegate :avatar, :name, :model, :kind, to: :equipment
  delegate :client, to: :location

  validates :location_id, :equipment_id, presence: true

  def next_service_dates
    service_dates.select("DISTINCT ON (kind) *").order(:kind, date: :desc)
  end

  def service_kinds
    SERVICE_KINDS[kind] || []
  end

  def last_service_date(service_kind)
    raise "Undefined activity kind" unless ACTIVITY_KIND.key?(service_kind)

    activities.where(kind: ACTIVITY_KIND[service_kind]).order(date: :desc).first&.date&.to_date || send(service_kind) # send(service_kind) is for legacy behaviour
  end

  def create_next_service_dates(from_date = Time.current, kinds = service_kinds)
    return if kinds.blank?

    kinds.each do |kind|
      next_date = from_date + send("#{kind}_interval").years
      service_dates.create(kind: kind, date: next_date)
    end
  end

  def calculate_next_service_date(service_kind, from_date = Time.current)
    from_date + send("#{service_kind}_interval").years
  end

  def condition_color
    CONDITIONS[condition][:color]
  end
end
