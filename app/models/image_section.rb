class ImageSection < ApplicationRecord
  MAX_IMAGES = 10

  belongs_to :section
  has_many_attached :images

  attr_reader :removed_image_ids, :pending_images

  validate :images_within_limit

  after_save :attach_pending_images
  after_save :purge_removed_images

  def pending_images=(images)
    @pending_images = images
    mark_attachment_change if Array(images).any?(&:present?)
  end

  def removed_image_ids=(ids)
    @removed_image_ids = ids
    mark_attachment_change if Array(ids).any?(&:present?)
  end

  private

  # pending_images is not a column. Without a real change, autosave skips an
  # existing section and after_save never attaches or purges.
  def mark_attachment_change
    self.updated_at = Time.current if persisted?
  end

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
    images_to_attach = Array(pending_images).select(&:present?)
    # Clear before attaching. This callback runs inside after_save, and
    # attach saves the record again. Leaving the list in place would re-enter
    # this method and replace the attachment change, keeping only one image.
    @pending_images = nil
    return if images_to_attach.empty?

    images.attach(images_to_attach)
  end

  def purge_removed_images
    ids = Array(removed_image_ids).reject(&:blank?)
    self.removed_image_ids = nil
    return if ids.empty?

    images.where(blob_id: ids).find_each(&:purge)
  end
end
