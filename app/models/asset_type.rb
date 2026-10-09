class AssetType < ApplicationRecord
  include Discard::Model

  SYSTEM_UPS_KEY = "ups"

  has_many :equipment_kinds

  before_validation :set_normalized_name

  validates :name, presence: true
  validates :system_key, uniqueness: {conditions: -> { kept }}, allow_nil: true
  validate :name_must_be_unique

  before_discard :prevent_discard_when_assigned_to_equipment_kind
  after_discard :reassign_equipment_kinds_to_ups

  scope :visible, -> { kept }

  def self.ups
    kept.find_by(system_key: SYSTEM_UPS_KEY) || create!(name: "UPS", system_key: SYSTEM_UPS_KEY)
  end

  def self.normalize_name(value)
    ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
  end

  def assigned_to_equipment_kind?
    equipment_kinds.visible.exists?
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

  def prevent_discard_when_assigned_to_equipment_kind
    return unless assigned_to_equipment_kind?

    errors.add(:base, "No se puede eliminar porque hay otros equipos asociados.")
    throw(:abort)
  end

  def reassign_equipment_kinds_to_ups
    ups = self.class.visible.find_by(system_key: SYSTEM_UPS_KEY)
    return if ups.nil?

    EquipmentKind.where(asset_type_id: id).update_all(asset_type_id: ups.id)
  end
end
