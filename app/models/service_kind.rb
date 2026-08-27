class ServiceKind < ApplicationRecord
  include Discard::Model

  LEGACY_KINDS = [
    {legacy_key: "service", name: "Service general", default_interval: 1},
    {legacy_key: "battery_change", name: "Cambio batería", default_interval: 2},
    {legacy_key: "belt_change", name: "Cambio correas", default_interval: 5},
    {legacy_key: "torque", name: "Torqueo", default_interval: 1},
    {legacy_key: "cleaning", name: "Limpieza", default_interval: 1},
    {legacy_key: "srt_900", name: "SRT-900", default_interval: 1},
    {legacy_key: "thermography", name: "Termografía", default_interval: 1},
    {legacy_key: "electrical_approval", name: "Apto eléctrico", default_interval: 1}
  ].freeze

  # Maps EquipmentKind.legacy_kind → ServiceKind.legacy_key so we can seed the
  # HABTM join to match LocationEquipment::SERVICE_KINDS until runtime reads
  # assignments from equipment_kinds_service_kinds instead of that constant.
  LEGACY_EQUIPMENT_ASSIGNMENTS = {
    "ups" => %w[battery_change],
    "power_unit" => %w[service battery_change belt_change],
    "electrical_panel" => %w[service torque cleaning],
    "building" => %w[srt_900 thermography electrical_approval]
  }.freeze

  attr_readonly :legacy_key

  has_and_belongs_to_many :equipment_kinds
  has_many :location_equipment_services, dependent: :restrict_with_error

  before_validation :set_normalized_name

  enum :interval_unit, {years: 0, months: 1, weeks: 2}, default: :years
  enum :priority, {critical: 0, normal: 1, low: 2}, default: :normal

  validates :name, presence: true
  validates :default_interval, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :interval_unit, presence: true
  validates :priority, presence: true
  validates :legacy_key, uniqueness: true, allow_nil: true
  validate :name_must_be_unique

  scope :visible, -> { kept }

  def self.normalize_name(value)
    ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
  end

  def self.interval_unit_options
    interval_units.keys.map do |unit|
      [I18n.t("activerecord.attributes.service_kind.interval_units.#{unit}"), unit]
    end
  end

  def self.priority_options
    priorities.keys.map do |priority|
      [I18n.t("activerecord.attributes.service_kind.priorities.#{priority}"), priority]
    end
  end

  def self.ensure_legacy_kinds!
    LEGACY_KINDS.each do |attrs|
      find_or_initialize_by(legacy_key: attrs[:legacy_key]).tap do |service_kind|
        next if service_kind.persisted?

        service_kind.assign_attributes(
          name: attrs[:name],
          default_interval: attrs[:default_interval],
          interval_unit: :years,
          priority: :normal
        )
        service_kind.save!
      end
    end
  end

  def self.ensure_legacy_equipment_assignments!
    ensure_legacy_kinds!

    LEGACY_EQUIPMENT_ASSIGNMENTS.each do |legacy_kind, legacy_keys|
      equipment_kind = EquipmentKind.find_by(legacy_kind: legacy_kind)
      next if equipment_kind.nil?

      legacy_keys.each do |legacy_key|
        service_kind = find_by(legacy_key: legacy_key)
        next if service_kind.nil?
        next if equipment_kind.service_kinds.exists?(service_kind.id)

        equipment_kind.service_kinds << service_kind
      end
    end
  end

  def interval_label
    unit = I18n.t("activerecord.attributes.service_kind.interval_units.#{interval_unit}")
    "#{default_interval} #{unit}"
  end

  def priority_label
    I18n.t("activerecord.attributes.service_kind.priorities.#{priority}")
  end

  private

  def set_normalized_name
    self.normalized_name = self.class.normalize_name(name)
  end

  def name_must_be_unique
    return if normalized_name.blank?

    scope = self.class.kept.where(normalized_name: normalized_name)
    scope = scope.where.not(id: id) if persisted?

    errors.add(:name, :taken) if scope.exists?
  end
end
