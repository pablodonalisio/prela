class ReportTemplate < ApplicationRecord
  SECTIONS = %w[
    equipment_specifications
    location_specifications
    measurements
    room_specifications
  ].freeze

  has_and_belongs_to_many :location_equipments

  validates :name, presence: true

  def active_sections
    self.class::SECTIONS.filter { |section| public_send(section).present? }
  end
end
