require 'zip'

class ReadDataAnalyzer < ActiveStorage::Analyzer
  extend AnalyzerHelper

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
      get_product_xml_file do |product_xml_file|
        cpnp_export_info = CpnpExport.new(product_xml_file)
        if cpnp_export_info.notification_status == "DR"
          Rails.logger.error "File Upload Error: Draft notification uploaded"
          raise DraftNotificationError
        else
          notification = ::Notification.new(product_name: cpnp_export_info.product_name,
                                            cpnp_reference: cpnp_export_info.cpnp_reference,
                                            cpnp_is_imported: cpnp_export_info.is_imported,
                                            cpnp_imported_country: cpnp_export_info.imported_country,
                                            shades: cpnp_export_info.shades,
                                            responsible_person: @notification_file.responsible_person)
          notification.notification_file_parsed!
          notification.save
        end

        if notification.errors.messages.present?
          if notification.errors.messages[:cpnp_reference].include? "Notification duplicated"
            Rails.logger.error "File Upload Error: A notification for this product already
              exists for this responsible person"
            raise NotificationDuplicationError
          elsif notification.errors.messages.values.any? { |message| message.include?("must not be blank") }
            missing_values = []
            messages.each { |key, value| missing_values << key if value.include? "must not be blank"}
            Rails.logger.error "File Upload Error: There is missing data in the
              notification: #{missing_values.join(', ')}"
            raise NotificationMissingDataError
          else
            Rails.logger.error "File Upload Error: Notification validation error"
            raise NotificationValidationError
          end
        end
      end
    rescue UnexpectedPdfFileError
      @notification_file.update(upload_error: :unzipped_files_are_pdf)
    rescue ProductFileNotFoundError
      @notification_file.update(upload_error: :product_file_not_found)
    rescue NotificationDuplicationError
      @notification_file.update(upload_error: :notification_duplicated)
    rescue NotificationMissingDataError
      @notification_file.update(upload_error: :notification_missing_data)
    rescue NotificationValidationError
      @notification_file.update(upload_error: :notification_validation_error)
    rescue DraftNotificationError
      @notification_file.update(upload_error: :draft_notification_error)
    end
  end

  def get_product_xml_file
    download_blob_to_tempfile do |zip_file|
      Zip::File.open(zip_file.path) do |files|
        file_found = false
        files.each do |file|
          if file_is_pdf?(file)
            raise UnexpectedPdfFileError
          elsif file_is_product_xml?(file)
            file_found = true
            yield file.get_input_stream.read
          end
        end
        raise ProductFileNotFoundError unless file_found
      end
    end
  end

  def file_is_product_xml?(file)
    file.name&.match?(get_xml_file_name_regex)
  end

  def get_xml_file_name_regex
    /[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}.*\.xml/
  end

  def file_is_pdf?(file)
    file.name&.match?(/.*\.pdf/)
  end

  def delete_notification_file
    @notification_file.destroy
  end

  class UnexpectedPdfFileError < StandardError
  end

  class ProductFileNotFoundError < StandardError
  end

  class NotificationDuplicationError < StandardError
  end

  class NotificationMissingDataError < StandardError
  end

  class NotificationValidationError < StandardError
  end

  class DraftNotificationError < StandardError
  end
end
