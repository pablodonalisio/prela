class Signature < ApplicationRecord
  include Discard::Model

  has_one_attached :image
  has_and_belongs_to_many :reports

  validates :name, :title, presence: true
  validate :image_must_be_attached

  private

  def image_must_be_attached
    errors.add(:image, :blank) unless image.attached?
  end
end
