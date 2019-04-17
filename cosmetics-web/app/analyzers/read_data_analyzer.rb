require 'zip'

class ReadDataAnalyzer < ActiveStorage::Analyzer
  extend AnalyzerHelper
  include CpnpStaticFiles

  def initialize(blob)
    super(blob)
  end

  def self.accept?(given_blob)
    return false unless given_blob.present? && given_blob.metadata["safe"]

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
    begin
      # rubocop:disable Metrics/BlockLength
      get_product_xml_file do |product_xml_file|
        cpnp_export_info = CpnpExport.new(product_xml_file)
        if cpnp_export_info.notification_status == "DR"
          raise DraftNotificationError, "DraftNotificationError - Draft notification uploaded"
        else
          notification = ::Notification.new(product_name: cpnp_export_info.product_name,
                                            shades: cpnp_export_info.shades,
                                            components: cpnp_export_info.components,
                                            cpnp_reference: cpnp_export_info.cpnp_reference,
                                            industry_reference: cpnp_export_info.industry_reference,
                                            cpnp_is_imported: cpnp_export_info.is_imported,
                                            cpnp_imported_country: cpnp_export_info.imported_country,
                                            cpnp_notification_date: cpnp_export_info.cpnp_notification_date,
                                            responsible_person: @notification_file.responsible_person,
                                            under_three_years: cpnp_export_info.under_three_years,
                                            still_on_the_market: cpnp_export_info.still_on_the_market,
                                            components_are_mixed: cpnp_export_info.components_are_mixed,
                                            ph_min_value: cpnp_export_info.ph_min_value,
                                            ph_max_value: cpnp_export_info.ph_max_value)
          notification.notification_file_parsed
          notification.save(context: :file_upload)
        end

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
    rescue DraftNotificationError => e
      Sidekiq.logger.error e.message
      @notification_file.update(upload_error: :draft_notification_error)
    rescue UnexpectedStaticFilesError => e
      Sidekiq.logger.error e.message
      @notification_file.update(upload_error: :unknown_error)
    rescue StandardError => e
      Sidekiq.logger.error "StandardError: #{e.message}\n #{e.backtrace}"
      @notification_file.update(upload_error: :unknown_error)
    end
    # rubocop:enable Metrics/BlockLength
  end

  def get_product_xml_file
    download_blob_to_tempfile do |zip_file|
      Zip::File.open(zip_file.path) do |files|
        if invalid_static_files(files)
          raise UnexpectedStaticFilesError, "UnexpectedStaticFilesError - a different static file was detected!"
        end

        file_found = false
        files.each do |file|
          next unless file_is_valid?(file)
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

  class FileUploadError < StandardError
    def initialize(error_message)
      @error_message = error_message
      super(@error_message)
    end

    def message
      "File Upload Error: #{@error_message}"
    end
  end

  class UnexpectedPdfFileError < FileUploadError
  end

  class ProductFileNotFoundError < FileUploadError
  end

  class DuplicateNotificationError < FileUploadError
  end

  class NotificationMissingDataError < FileUploadError
  end

  class NotificationValidationError < FileUploadError
  end

  class DraftNotificationError < FileUploadError
  end

  class UnexpectedStaticFilesError < FileUploadError
  end
end
