class ReportTask < ApplicationRecord
  belongs_to :report

  validates :name, presence: true
  validates :position, numericality: {only_integer: true, greater_than_or_equal_to: 0}
end
