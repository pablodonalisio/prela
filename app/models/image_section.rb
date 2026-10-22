class ImageSection < ApplicationRecord
  MAX_IMAGES = 10

  belongs_to :section
  has_many_attached :images

  attr_accessor :removed_image_ids, :pending_images

  validate :images_within_limit

  after_save :attach_pending_images
  after_save :purge_removed_images

  private

  def images_within_limit
    return if projected_image_count <= MAX_IMAGES

    errors.add(:images, "no puede tener más de #{MAX_IMAGES} imágenes.")
  end

  def projected_image_count
    current = images.attachments.size
    removed = Array(removed_image_ids).count(&:present?)
    added = Array(pending_images).count(&:present?)
    [current - removed, 0].max + added
  end

  def attach_pending_images
    Array(pending_images).each do |image|
      next if image.blank?

      images.attach(image)
    end
    self.pending_images = nil
  end

  def purge_removed_images
    ids = Array(removed_image_ids).reject(&:blank?)
    self.removed_image_ids = nil
    return if ids.empty?

    images.where(blob_id: ids).find_each(&:purge)
  end
end
