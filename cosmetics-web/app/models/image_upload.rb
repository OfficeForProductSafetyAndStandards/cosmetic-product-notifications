class ImageUpload < ApplicationRecord
  belongs_to :notification

  has_one_attached :file

  validate :attached_file_is_image?

  def file_exists?
    file.attachment.present?
  end

  def marked_as_safe?
    file_exists? && file.metadata["safe"]
  end

  ALLOWED_CONTENT_TYPES = %w[image/jpeg application/pdf image/png image/svg+xml]

  def attached_file_is_image?
    unless file.attachment.nil? || ALLOWED_CONTENT_TYPES.include?(file.blob.content_type)
      errors.add :file, "must be one of " + ALLOWED_CONTENT_TYPES.join(", ")
    end
  end
end
