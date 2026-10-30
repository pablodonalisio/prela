class SupplyKind < ApplicationRecord
  include Discard::Model

  has_many :supplies, dependent: :restrict_with_error

  before_validation :set_normalized_name
  before_validation :normalize_description
  before_discard :reject_when_supplies_remain

  validates :name, presence: true
  validate :name_must_be_unique

  scope :visible, -> { kept }

  def self.normalize_name(value)
    ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
  end

  private

  def set_normalized_name
    self.normalized_name = self.class.normalize_name(name)
  end

  def normalize_description
    self.description = description.to_s.strip.presence
  end

  def name_must_be_unique
    return if normalized_name.blank?

    scope = self.class.kept.where(normalized_name: normalized_name)
    scope = scope.where.not(id: id) if persisted?

    errors.add(:name, :taken) if scope.exists?
  end

  def reject_when_supplies_remain
    return unless supplies.kept.exists?

    errors.add(:base, "No se puede eliminar el tipo porque tiene insumos.")
    throw :abort
  end
end
