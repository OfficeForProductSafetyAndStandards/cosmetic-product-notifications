class NotificationFile < ApplicationRecord
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
    unknown_error: "unknown_error",
  }

  @allowed_content_types = %w[application/zip application/x-zip-compressed].freeze
  @max_file_size_bytes = 30.megabytes
  @max_number_of_files = 100

  def self.get_content_types
    @allowed_content_types
  end

  def self.get_max_file_size
    @max_file_size_bytes
  end

  def self.get_max_number_of_files
    @max_number_of_files
  end

  def upload_error_message
    I18n.t("activerecord.attributes.notification_file.upload_errors.#{upload_error}")
  end

private

  def uploaded_file_is_zip?
    unless uploaded_file.attachment.nil? || NotificationFile.get_content_types.include?(uploaded_file.blob.content_type)
      self.upload_error = "uploaded_file_not_a_zip"
    end
  end

  def uploaded_file_is_within_allowed_size?
    unless uploaded_file.attachment.nil? || uploaded_file.blob.byte_size <= NotificationFile.get_max_file_size
      self.upload_error = "file_size_too_big"
    end
  end
end
