class Equipment < ApplicationRecord
  include Discard::Model

  LEGACY_KINDS = %w[ups power_unit electrical_panel building].freeze

  has_one_attached :avatar
  belongs_to :equipment_kind
  has_many :location_equipments
  has_many :equipment_supplies, dependent: :destroy, as: :equipmentable
  has_one :equipment_battery, dependent: :destroy, as: :equipmentable, class_name: "EquipmentSupply"
  has_one :battery, through: :equipment_battery, source: :suppliable, source_type: "Battery"

  delegate :legacy_kind, to: :equipment_kind, allow_nil: true

  validates :name, presence: true

  scope :visible, -> { kept.where(equipment_kind_id: EquipmentKind.kept.select(:id)) }

  LEGACY_KINDS.each do |legacy_kind|
    define_method("#{legacy_kind}?") { self.legacy_kind == legacy_kind }
  end

  def self.legacy_kinds_for_select
    LEGACY_KINDS.map do |legacy_kind|
      [I18n.t("activerecord.attributes.equipment.kinds.#{legacy_kind}"), legacy_kind]
    end
  end

  def kind
    legacy_kind
  end
end
