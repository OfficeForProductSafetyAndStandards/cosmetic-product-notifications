class ImageUpload < ApplicationRecord
  include FileUploadConcern
  set_attachment_name :file
  set_allowed_types %w[image/jpeg application/pdf image/png].freeze
  set_max_file_size 30.megabytes

  belongs_to :notification

  has_one_attached :file

  def file_exists?
    file.attachment.present?
  end

  def file_missing?
    !file_exists?
  end

  def marked_as_safe?
    file_exists? && metadata_safe
  end

  def metadata_safe
    return true if ENV["ANTIVIRUS_ENABLED"] == "false"

    file.metadata["safe"]
  end
end
