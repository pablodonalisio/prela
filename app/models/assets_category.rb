class AssetsCategory < ApplicationRecord
  include Discard::Model

  has_many :equipment_kinds

  before_validation :set_normalized_name

  validates :name, presence: true
  validate :name_must_be_unique

  before_discard :prevent_discard_when_assigned_to_equipment_kind

  scope :visible, -> { kept }

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
end
