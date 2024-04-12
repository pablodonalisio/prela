class Report < ApplicationRecord
  belongs_to :location_equipment

  has_one_attached :pdf
  has_one :ups_report_stat, dependent: :destroy

  accepts_nested_attributes_for :ups_report_stat
end
