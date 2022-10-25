class ImageUpload < ApplicationRecord
  include FileUploadConcern
  include FileAntivirusCheckable

  set_attachment_name :file
  set_allowed_types %w[image/jpeg application/pdf image/png].freeze
  set_max_file_size 30.megabytes

  belongs_to :notification, touch: true

  has_one_attached :file

  delegate :responsible_person, to: :notification
end
