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

  def failed_antivirus_check?
    file_exists? && virus_safe == false
  end

  def passed_antivirus_check?
    # We want to return 'false' (not nil) when the virus_safe is 'nil'
    file_exists? && virus_safe == true
  end

  def pending_antivirus_check?
    file_exists? && virus_safe.nil?
  end

private

  def virus_safe
    return true if ENV["ANTIVIRUS_ENABLED"] == "false"

    file.metadata["safe"]
  end
end
