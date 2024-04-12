class UpsReportStat < ApplicationRecord
  belongs_to :report

  validates :battery_charge, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100}
end
