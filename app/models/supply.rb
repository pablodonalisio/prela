class Supply < ApplicationRecord
  include Discard::Model
  include Filterable

  belongs_to :supply_kind
  has_one_attached :avatar
  has_many :replacement_links, class_name: "SupplyReplacement", foreign_key: :supply_id, inverse_of: :supply, dependent: :destroy
  has_many :replaced_by_links, class_name: "SupplyReplacement", foreign_key: :replacement_id, inverse_of: :replacement, dependent: :destroy

  before_validation :set_normalized_name
  before_validation :normalize_reference_url
  before_discard :remove_replacement_pairs
  after_save :sync_replacements, if: :replacement_ids_assigned?

  validates :name, presence: true
  validate :name_must_be_unique
  validate :supply_kind_must_be_visible

  scope :visible, -> { kept }
  scope :by_supply_kind_ids, ->(supply_kind_ids) { where(supply_kind_id: supply_kind_ids) }
  scope :by_name, ->(name) {
    normalize_name(name).split.reduce(all) do |scope, token|
      scope.where("normalized_name ILIKE ?", "%#{sanitize_sql_like(token)}%")
    end
  }

  def self.normalize_name(value)
    ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
  end

  def replacement_ids
    return @replacement_ids if replacement_ids_assigned?

    SupplyReplacement.partner_ids_for(id)
  end

  def replacement_ids=(ids)
    @replacement_ids_assigned = true
    @replacement_ids = Array(ids).flatten.compact_blank.map(&:to_i).uniq
  end

  def replacement_supplies
    partners = if association(:replacement_links).loaded? && association(:replaced_by_links).loaded?
      replacement_links.map(&:replacement) + replaced_by_links.map(&:supply)
    else
      self.class.kept.where(id: SupplyReplacement.partner_ids_for(id)).to_a
    end

    partners.uniq.select(&:kept?).sort_by(&:name)
  end

  private

  def replacement_ids_assigned?
    @replacement_ids_assigned
  end

  def set_normalized_name
    self.normalized_name = self.class.normalize_name(name)
  end

  def normalize_reference_url
    self.reference_url = reference_url.to_s.strip.presence
  end

  def name_must_be_unique
    return if normalized_name.blank?

    scope = self.class.kept.where(normalized_name: normalized_name)
    scope = scope.where.not(id: id) if persisted?

    errors.add(:name, :taken) if scope.exists?
  end

  def supply_kind_must_be_visible
    return if supply_kind.blank? || supply_kind.kept?

    errors.add(:supply_kind, "no está disponible")
  end

  def remove_replacement_pairs
    SupplyReplacement.where(supply_id: id).delete_all
    SupplyReplacement.where(replacement_id: id).delete_all
  end

  def sync_replacements
    desired_ids = @replacement_ids
    @replacement_ids_assigned = false

    desired = self.class.kept.where(id: desired_ids).where.not(id: id).pluck(:id)
    current = SupplyReplacement.partner_ids_for(id)

    (current - desired).each do |other_id|
      low, high = [id, other_id].minmax
      SupplyReplacement.where(supply_id: low, replacement_id: high).delete_all
    end

    (desired - current).each do |other_id|
      low, high = [id, other_id].minmax
      SupplyReplacement.create!(supply_id: low, replacement_id: high)
    end
  end
end
