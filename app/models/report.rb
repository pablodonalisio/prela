class Report < ApplicationRecord
  belongs_to :location_equipment

  has_one_attached :pdf
  has_many_attached :images
  has_one :ups_report_stat, dependent: :destroy
  has_one :room_report_stat, dependent: :destroy

  accepts_nested_attributes_for :ups_report_stat
  accepts_nested_attributes_for :room_report_stat

  validates :date, presence: true
end
