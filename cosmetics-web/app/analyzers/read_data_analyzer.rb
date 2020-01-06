require "zip"

class ReadDataAnalyzer < ActiveStorage::Analyzer
  class FileUploadError < StandardError
    def initialize(error_message)
      @error_message = error_message
      super(@error_message)
    end

    def message
      "File Upload Error: #{@error_message}"
    end
  end

  class UnexpectedPdfFileError < FileUploadError; end
  class ProductFileNotFoundError < FileUploadError; end
  class DuplicateNotificationError < FileUploadError; end
  class NotificationMissingDataError < FileUploadError; end
  class NotificationValidationError < FileUploadError; end
  class UnexpectedStaticFilesError < FileUploadError; end

  extend AnalyzerHelper
  include CpnpStaticFiles

  def initialize(blob)
    super(blob)
  end

  def self.accept?(given_blob)
    return false if given_blob.blank?

    if ENV.fetch("ANTIVIRUS_ENABLED", "true") == "true"
      return false unless given_blob.metadata["safe"]
    end

    notification_file = get_notification_file_from_blob(given_blob)
    notification_file.present? && notification_file.upload_error.blank?
  end

  def metadata
    @notification_file = self.class.get_notification_file_from_blob(blob)
    create_notification_from_file
    delete_notification_file if @notification_file.upload_error.blank?
    {}
  end

private

  def create_notification_from_file
    get_product_xml_file do |product_xml_file|
      cpnp_export_info = CpnpParser.new(product_xml_file)
      cpnp_exporter    = CpnpNotificationImporter.new(cpnp_export_info, @notification_file.responsible_person)

      cpnp_exporter.create!
      notification = cpnp_exporter.notification

      if notification.errors.messages.present?
        if notification.errors.messages[:cpnp_reference].include? Notification.duplicate_notification_message
          raise DuplicateNotificationError, "DuplicateNotificationError - A notification for this product already
            exists for this responsible person (CPNP reference no. #{notification.cpnp_reference})"
        else
          raise NotificationValidationError, "NotificationValidationError - #{notification.errors.messages}"
        end
      else
        Sidekiq.logger.info "Successful File Upload"
      end
    end
  rescue UnexpectedPdfFileError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :unzipped_files_are_pdf)
  rescue ProductFileNotFoundError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :product_file_not_found)
  rescue DuplicateNotificationError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :notification_duplicated)
  rescue NotificationValidationError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :notification_validation_error)
  rescue CpnpNotificationImporter::DraftNotificationError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :draft_notification_error)
  rescue UnexpectedStaticFilesError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :unknown_error)
  rescue CpnpNotificationImporter::CpnpFileNotifiedPostBrexitError => e
    Sidekiq.logger.error e.message
    @notification_file.update(upload_error: :post_brexit_date)
  rescue StandardError => e
    Sidekiq.logger.error "StandardError: #{e.message}\n #{e.backtrace}"
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
    file.name&.match?(product_xml_file_name_regex)
  end

  def file_is_valid?(file)
    file.file? && file.name !~ /__MACOSX/ && file.name !~ /\.DS_Store/
  end

  def file_is_pdf?(file)
    file.name&.match?(/.*\.pdf/)
  end

  def product_xml_file_name_regex
    /[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}.*\.xml/
  end

  def delete_notification_file
    @notification_file.destroy
  end
end
