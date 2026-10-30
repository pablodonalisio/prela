class SupplyReplacement < ApplicationRecord
  belongs_to :supply
  belongs_to :replacement, class_name: "Supply"

  before_validation :order_pair

  validates :replacement_id, uniqueness: {scope: :supply_id}
  validate :pair_must_be_distinct

  def self.partner_ids_for(supply_id)
    return [] if supply_id.blank?

    where(supply_id: supply_id).pluck(:replacement_id) +
      where(replacement_id: supply_id).pluck(:supply_id)
  end

  private

  def order_pair
    return if supply_id.blank? || replacement_id.blank? || supply_id < replacement_id

    self.supply_id, self.replacement_id = replacement_id, supply_id
  end

  def pair_must_be_distinct
    return if supply_id.blank? || replacement_id.blank?
    return if supply_id != replacement_id

    errors.add(:replacement, "no puede ser el mismo insumo")
  end
end
