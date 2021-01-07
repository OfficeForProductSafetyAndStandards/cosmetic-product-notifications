require "zip"

class NotificationFileProcessorJob < ApplicationJob
  class UnexpectedPdfFileError < FileUploadError; end
  class ProductFileNotFoundError < FileUploadError; end
  class NotificationMissingDataError < FileUploadError; end
  class UnexpectedStaticFilesError < FileUploadError; end

  include CpnpStaticFiles
  include ActiveStorage::Downloading

  def perform(notification_file_id)
    @notification_file = NotificationFile.find(notification_file_id)

    return if @notification_file.upload_error.present?

    create_notification_from_file
    delete_notification_file if @notification_file.upload_error.blank?
  end

private

  def blob
    @notification_file.uploaded_file.blob
  end

  def create_notification_from_file
    get_product_xml_file do |product_xml_file|
      cpnp_import_info = CpnpParser.new(product_xml_file)
      cpnp_import      = CpnpNotificationImporter.new(cpnp_import_info, @notification_file.responsible_person)

      cpnp_import.create!

      Sidekiq.logger.info "Successful File Upload"
    end
  rescue Zip::Error => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :uploaded_file_not_a_zip)
  rescue UnexpectedPdfFileError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :unzipped_files_are_pdf)
  rescue ProductFileNotFoundError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :product_file_not_found)
  rescue CpnpNotificationImporter::DuplicateNotificationError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :notification_duplicated)
  rescue CpnpNotificationImporter::NotificationValidationError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :notification_validation_error)
  rescue CpnpNotificationImporter::DraftNotificationError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :draft_notification_error)
  rescue UnexpectedStaticFilesError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :unknown_error)
  rescue StandardError => e
    Sidekiq.logger.error "StandardError: #{e.message}\n #{e.backtrace}"
    Raven.capture_exception(e)
    @notification_file.update(upload_error: :unknown_error)
  end

  def get_product_xml_file
    download_blob_to_tempfile do |zip_file|
      Zip::File.open(zip_file.path) do |files|
        valid_files = files.select { |file| file_is_valid?(file) }
        if invalid_static_files(valid_files)
          raise UnexpectedStaticFilesError, "UnexpectedStaticFilesError - a different static file was detected!"
        end

        file_found = false
        valid_files.each do |file|
          if file_is_pdf?(file)
            raise UnexpectedPdfFileError, "UnexpectedPdfFileError - The unzipped files are PDF files"
          elsif file_is_product_xml?(file)
            file_found = true
            yield file.get_input_stream.read
          end
        end
        unless file_found
          raise ProductFileNotFoundError, "ProductFileNotFoundError - The ZIP file does not contain a product
             XML file"
        end
      end
    end
  end

  def invalid_static_files(files)
    files.any? do |file|
      static_file?(file) && file_contents_differs?(file)
    end
  end

  def file_is_product_xml?(file)
    File.basename(file.name).match?(product_xml_file_name_regex)
  end

  def file_is_valid?(file)
    file.file? && file.name !~ /__MACOSX/ && file.name !~ /\.DS_Store/
  end

  def file_is_pdf?(file)
    file.name&.match?(/.*\.pdf/)
  end

  def product_xml_file_name_regex
    /\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}.*\.xml\z/
  end

  def delete_notification_file
    @notification_file.destroy!
  end
end
