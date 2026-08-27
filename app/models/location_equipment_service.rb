class LocationEquipmentService < ApplicationRecord
  belongs_to :location_equipment
  belongs_to :service_kind

  enum :interval_unit, {years: 0, months: 1, weeks: 2}, default: :years

  validates :interval, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :interval_unit, presence: true
  validates :service_kind_id, uniqueness: {scope: :location_equipment_id}

  def self.interval_unit_options
    interval_units.keys.map do |unit|
      [I18n.t("activerecord.attributes.service_kind.interval_units.#{unit}"), unit]
    end
  end

  def interval_label
    unit = I18n.t("activerecord.attributes.service_kind.interval_units.#{interval_unit}")
    "#{interval} #{unit}"
  end

  def advance(from_date = Time.current)
    from_date + interval.public_send(interval_unit)
  end
end
