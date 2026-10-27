class TableLabel < ApplicationRecord
  AXES = %w[row column corner].freeze

  belongs_to :table_section

  validates :axis, inclusion: {in: AXES}
  validates :position, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :label, presence: true, if: :requires_title?

  def header?
    axis.in?(%w[row column])
  end

  private

  def requires_title?
    header? && table_section&.owned_by_template?
  end
end
