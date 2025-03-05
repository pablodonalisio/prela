class Activity < ApplicationRecord
  SERVICE = "Service general"
  BATTERY_CHANGE = "Cambio batería"
  BELT_CHANGE = "Cambio correas"
  OTHER = "Otro"
  KINDS = {
    SERVICE => :service,
    BATTERY_CHANGE => :battery_change,
    BELT_CHANGE => :belt_change,
    OTHER => :other
  }

  belongs_to :location_equipment
  has_one_attached :document
  has_one :service_date, dependent: :destroy

  after_create :create_service_date
  after_update :update_service_date

  validates :description, :date, :kind, presence: true

  def create_service_date
    activity_kind = KINDS[kind]
    service_kind = ServiceDate.kinds.key?(activity_kind) ? activity_kind : nil
    return unless service_kind

    date = location_equipment.calculate_next_service_date(service_kind, self.date)
    location_equipment.service_dates.create!(kind: service_kind, date: date, activity: self)
  end

  def update_service_date
    create_service_date if service_date.nil?
    return unless previous_changes.include?("date") || previous_changes.include?("kind")

    update_service_date_date if previous_changes.include?("date")
    update_service_date_kind if previous_changes.include?("kind")

    service_date.save
  end

  private

  def update_service_date_date
    service_date.date = location_equipment.calculate_next_service_date(KINDS[kind], date)
  end

  def update_service_date_kind
    service_date.kind = KINDS[kind]
    service_date.date = location_equipment.calculate_next_service_date(KINDS[kind], date)
  end
end
