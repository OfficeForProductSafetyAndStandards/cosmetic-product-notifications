class NotificationFile < ApplicationRecord
  has_one_attached :uploaded_file
  belongs_to :responsible_person
  belongs_to :user

  validate :uploaded_file_is_zip?
  validate :uploaded_file_is_within_allowed_size?


  enum upload_error: [
      :uploaded_file_not_a_zip,
      :unzipped_files_not_xml,
      :unzipped_files_are_pdf,
      :file_flagged_as_virus,
      :file_size_too_big,
      :notification_validation_error,
      :notification_duplicated,
      :unknown_error
  ]

  @max_file_size_bytes = 30.megabytes

  def self.get_max_file_size
    @max_file_size_bytes
  end

private

  def uploaded_file_is_zip?
    unless uploaded_file.attachment.nil? || uploaded_file.blob.content_type == "application/zip"
      self.upload_error = "uploaded_file_not_a_zip"
    end
  end

  def uploaded_file_is_within_allowed_size?
    unless uploaded_file.attachment.nil? || uploaded_file.blob.byte_size <= NotificationFile.get_max_file_size
      self.upload_error = "file_size_too_big"
    end
  end
end
