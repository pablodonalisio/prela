class Tag < ApplicationRecord
  include Discard::Model

  DEFAULT_COLOR = "#6c757d"
  HEX_COLOR_FORMAT = /\A#[0-9A-Fa-f]{6}\z/

  has_many :taggings, dependent: :destroy

  before_validation :set_normalized_name
  before_validation :normalize_color

  validates :name, presence: true
  validates :color, presence: true, format: {with: HEX_COLOR_FORMAT}
  validate :name_must_be_unique

  scope :visible, -> { kept }

  def self.normalize_name(value)
    ActiveSupport::Inflector.transliterate(value.to_s.strip.downcase)
  end

  def badge_style
    "background-color: #{color}; color: #{contrast_text_color};"
  end

  def contrast_text_color
    r, g, b = color.delete("#").scan(/../).map { |hex| hex.to_i(16) / 255.0 }
    luminance = (0.2126 * linearize(r)) + (0.7152 * linearize(g)) + (0.0722 * linearize(b))
    luminance > 0.55 ? "#212529" : "#ffffff"
  end

  def location_equipments_count
    LocationEquipment.visible.joins(:taggings).where(taggings: {tag_id: id}).distinct.count
  end

  private

  def set_normalized_name
    self.normalized_name = self.class.normalize_name(name)
  end

  def normalize_color
    return if color.blank?

    value = color.to_s.strip
    value = "##{value}" unless value.start_with?("#")
    self.color = value.downcase
  end

  def name_must_be_unique
    return if normalized_name.blank?

    scope = self.class.kept.where(normalized_name: normalized_name)
    scope = scope.where.not(id: id) if persisted?

    errors.add(:name, :taken) if scope.exists?
  end

  def linearize(channel)
    channel <= 0.03928 ? channel / 12.92 : ((channel + 0.055) / 1.055)**2.4
  end
end
