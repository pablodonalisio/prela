class LocationEquipmentService < ApplicationRecord
  belongs_to :location_equipment
  belongs_to :service_kind

  enum :interval_unit, {years: 0, months: 1, weeks: 2}, validate: {allow_nil: true}

  before_validation :normalize_interval_for_kind

  validates :service_kind_id, uniqueness: {scope: :location_equipment_id}
  validates :interval, presence: true, numericality: {only_integer: true, greater_than: 0}, if: :recurring?
  validates :interval_unit, presence: true, if: :recurring?
  validate :interval_must_be_blank_when_not_recurring

  def self.interval_unit_options
    interval_units.keys.map do |unit|
      [I18n.t("activerecord.attributes.service_kind.interval_units.#{unit}"), unit]
    end
  end

  def recurring?
    service_kind&.recurring?
  end

  def interval_label
    return service_kind.one_time_label unless recurring?

    unit = I18n.t("activerecord.attributes.service_kind.interval_units.#{interval_unit}")
    "#{interval} #{unit}"
  end

  def advance(from_date = Time.current)
    return nil unless recurring?

    from_date + interval.public_send(interval_unit)
  end

  private

  def normalize_interval_for_kind
    return if service_kind.blank?

    unless service_kind.recurring?
      self.interval = nil
      self.interval_unit = nil
      return
    end

    return if interval.present? && interval_unit.present?

    self.interval = service_kind.default_interval
    self.interval_unit = service_kind.interval_unit
  end

  def interval_must_be_blank_when_not_recurring
    return if recurring?

    errors.add(:interval, :present) if interval.present?
    errors.add(:interval_unit, :present) if interval_unit.present?
  end
end
