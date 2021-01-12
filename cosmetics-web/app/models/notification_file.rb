class NotificationFile < ApplicationRecord
  ALLOWED_CONTENT_TYPES = %w[application/zip application/x-zip-compressed].freeze
  MAX_FILE_SIZE_BYTES = 30.megabytes
  MAX_NUMBER_OF_FILES = 100

  has_one_attached :uploaded_file

  belongs_to :responsible_person
  belongs_to :user

  validate :uploaded_file_is_zip?
  validate :uploaded_file_is_within_allowed_size?

  enum upload_error: {
    uploaded_file_not_a_zip: "uploaded_file_not_a_zip",
    file_size_too_big: "file_size_too_big",
    file_flagged_as_virus: "file_flagged_as_virus",
    unzipped_files_are_pdf: "unzipped_files_are_pdf",
    product_file_not_found: "product_file_not_found",
    notification_duplicated: "notification_duplicated",
    notification_validation_error: "notification_validation_error",
    draft_notification_error: "draft_notification_error",
    file_upload_failed: "file_upload_failed",
    unknown_error: "unknown_error",
  }

  def upload_error_message
    I18n.t("activerecord.attributes.notification_file.upload_errors.#{upload_error}")
  end

private

  def uploaded_file_is_zip?
    unless uploaded_file.attachment.nil? || ALLOWED_CONTENT_TYPES.include?(uploaded_file.blob.content_type)
      self.upload_error = "uploaded_file_not_a_zip"
    end
  end

  def uploaded_file_is_within_allowed_size?
    unless uploaded_file.attachment.nil? || uploaded_file.blob.byte_size <= MAX_FILE_SIZE_BYTES
      self.upload_error = "file_size_too_big"
    end
  end
end
