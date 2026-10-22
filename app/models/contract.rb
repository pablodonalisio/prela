class Contract < ApplicationRecord
  include Discard::Model

  belongs_to :client
  has_one_attached :file

  validates :name, :file, :starts_on, :ends_on, presence: true
  validate :ends_on_on_or_after_starts_on

  scope :visible, -> { kept }

  private

  def ends_on_on_or_after_starts_on
    return if starts_on.blank? || ends_on.blank?
    return if ends_on >= starts_on

    errors.add(:ends_on, "debe ser posterior o igual a la fecha de inicio")
  end
end
