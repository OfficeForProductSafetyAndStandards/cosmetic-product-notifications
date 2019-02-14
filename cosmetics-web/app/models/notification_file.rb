class NotificationFile < ApplicationRecord
  has_one_attached :uploaded_file
  belongs_to :responsible_person
  belongs_to :user

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
end
