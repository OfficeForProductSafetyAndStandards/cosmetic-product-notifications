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
      get_product_xml_file do |product_xml_file|
        cpnp_export_info = CpnpExport.new(product_xml_file)
        notification = ::Notification.new(product_name: cpnp_export_info.product_name,
                                          cpnp_reference: cpnp_export_info.cpnp_reference,
                                          cpnp_is_imported: cpnp_export_info.is_imported,
                                          cpnp_imported_country: cpnp_export_info.imported_country,
                                          shades: cpnp_export_info.shades,
                                          components: cpnp_export_info.components,
                                          responsible_person: @notification_file.responsible_person)
        notification.notification_file_parsed!
        notification.save
      end
    rescue UnexpectedPdfFileError
      @notification_file.update(upload_error: :unzipped_files_are_pdf)
    rescue ProductFileNotFoundError
      @notification_file.update(upload_error: :product_file_not_found)
    rescue UnexpectedFileError
      @notification_file.update(upload_error: :unzipped_files_not_xml)
    rescue UnexpectedStaticFilesError
      @notification_file.update(upload_error: :static_files_differs)
    end
  end

  def get_product_xml_file
    download_blob_to_tempfile do |zip_file|
      Zip::File.open(zip_file.path) do |files|
        if invalid_static_files(files)
          raise UnexpectedStaticFilesError
        end

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

  def invalid_static_files(files)
    files.any? do |file|
      differs = is_static_file(file) && static_file_contents_differs(file)
      if differs
        Rails.logger.error "***** WARNING - different static file was detected! *****"
        Rails.logger.error "Filename: #{file.name}"
      end
      differs
    end
  end

  def file_is_product_xml?(file)
    file.name&.match?(get_xml_file_name_regex)
  end

  def file_is_pdf?(file)
    file.name&.match?(/.*\.pdf/)
  end

  def get_xml_file_name_regex
    /[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}.*\.xml/
  end

  def delete_notification_file
    @notification_file.destroy
  end

  class UnexpectedStaticFilesError < StandardError
  end

  class UnexpectedPdfFileError < StandardError
  end

  class UnexpectedFileError < StandardError
  end

  class ProductFileNotFoundError < StandardError
  end
end
