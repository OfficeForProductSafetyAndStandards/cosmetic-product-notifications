class ImageUpload < ApplicationRecord
  belongs_to :notification, touch: true

  # BEGIN: File uploads
  # The parent notification limits the maximum number of image uploads
  # per notification to 10.
  include FileUploadConcern
  include FileAntivirusConcern

  has_one_attached :file
  set_attachment_name :file
  set_attachment_name_for_antivirus :file
  set_allowed_types %w[image/jpeg application/pdf image/png].freeze
  set_max_file_size 30.megabytes
  # END: File uploads

  delegate :responsible_person, to: :notification
end
