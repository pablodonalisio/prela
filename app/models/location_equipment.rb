class LocationEquipment < ApplicationRecord
  include Discard::Model
  include Filterable
  include Taggable

  has_paper_trail

  # Metrics (failures average, etc.) start at this date for equipment created earlier.
  # Equipment created on/after this date use created_at instead.
  FAILURE_METRICS_START_DATE = Date.new(2026, 8, 10)

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

  has_one_attached :avatar
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
  has_many :comments, dependent: :destroy

  scope :visible, -> {
    kept
      .where(location_id: Location.visible.select(:id))
      .where(equipment_id: Equipment.visible.select(:id))
  }
  scope :by_client_ids, ->(client_id) { joins(:location).where(location: {client_id:}) }
  scope :by_location_ids, ->(location_id) { where(location_id:) }
  scope :by_status, ->(status) { where(status:) }
  scope :by_equipment_kind_ids, ->(equipment_kind_ids) { joins(:equipment).where(equipment: {equipment_kind_id: equipment_kind_ids}) }
  scope :by_tag_ids, ->(tag_ids) { joins(:tags).where(tags: {id: tag_ids}).distinct }

  enum :status, {active: 0, out_of_service: 1}

  delegate :name, :model, :kind, to: :equipment
  delegate :client, to: :location

  validates :location_id, :equipment_id, presence: true

  def display_avatar
    avatar.attached? ? avatar : equipment.avatar
  end

  def associate_report_template!(report_template)
    return if report_template.blank?
    return if report_templates.exists?(report_template.id)

    report_templates << report_template
  end

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

  def failure_metrics_start_at
    [created_at, FAILURE_METRICS_START_DATE.beginning_of_day].max
  end

  def failures_since_metrics_start
    failures.where(date: failure_metrics_start_at.to_date..Date.current).count
  end

  def failures_last_year_count
    failures.where(date: 1.year.ago.to_date..Date.current).count
  end

  def active_seconds_since_metrics_start
    ActiveDuration.new(self).seconds
  end

  def active_years_since_metrics_start
    ActiveDuration.new(self).years
  end

  def average_failures_per_active_year
    years = active_years_since_metrics_start
    return if years <= 0

    failures_since_metrics_start / years.to_f
  end
end
