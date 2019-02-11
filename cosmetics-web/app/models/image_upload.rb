class ImageUpload < ApplicationRecord
  belongs_to :notification

  has_one_attached :file

  validate :attached_file_is_image?
  validate :attached_file_is_within_allowed_size?

  def file_exists?
    file.attachment.present?
  end

  def file_missing?
    !file_exists?
  end

  def marked_as_safe?
    file_exists? && file.metadata["safe"]
  end

  @allowed_content_types = %w[image/jpeg application/pdf image/png image/svg+xml].freeze
  @max_file_size_bytes = 30.megabytes

  def self.get_content_types
    @allowed_content_types
  end

  def self.get_max_file_size
    @max_file_size_bytes
  end

private

  def attached_file_is_image?
    unless file.attachment.nil? || ImageUpload.get_content_types.include?(file.blob.content_type)
      errors.add :file, "must be one of " + ImageUpload.get_content_types.join(", ")
    end
  end

  def attached_file_is_within_allowed_size?
    unless file.attachment.nil? || file.blob.byte_size <= ImageUpload.get_max_file_size
      errors.add :file, "must be smaller than #{ImageUpload.get_max_file_size / 1.megabyte}MB"
    end
  end
end
