class ImageUpload < ApplicationRecord
  belongs_to :notification

  has_one_attached :file

  def file_exists?
    file.attachment.present?
  end

  def marked_as_safe?
    file_exists? && file.metadata["safe"]
  end
end
