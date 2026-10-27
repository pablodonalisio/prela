class ListSection < ApplicationRecord
  belongs_to :section
  has_many :list_items, -> { order(:position) }, dependent: :destroy, autosave: true, inverse_of: :list_section

  accepts_nested_attributes_for :list_items, allow_destroy: true, reject_if: :reject_blank_item

  before_validation :normalize_item_positions

  private

  def normalize_item_positions
    list_items.reject(&:marked_for_destruction?).each_with_index do |item, index|
      item.position = index
    end
  end

  def reject_blank_item(attributes)
    attributes["name"].blank? && attributes["id"].blank?
  end
end
