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
    create_notification_from_file
    delete_notification_file
    {}
  end

private

  def create_notification_from_file
    notification_file = self.class.get_notification_file_from_blob(blob)

    get_xml_file_content do |xml_file_content|
      if xml_file_content.blank?
        if contains_pdf?
          notification_file.update(upload_error: :unzipped_files_are_pdf)
        else
          notification_file.update(upload_error: :unzipped_files_not_xml)
        end
      else
        @xml_info = CpnpExport.new(xml_file_content)

        notification = ::Notification.new(product_name: @xml_info.product_name,
                                          cpnp_reference: @xml_info.cpnp_reference,
                                          cpnp_is_imported: @xml_info.is_imported,
                                          cpnp_imported_country: @xml_info.imported_country,
                                          shades: @xml_info.shades,
                                          responsible_person: notification_file.responsible_person)
        notification.notification_file_parsed!
        notification.save
      end
    end
  end

  def get_xml_file_content
    download_blob_to_tempfile do |file|
      Zip::File.open(file.path) do |zipped_files|
        zipped_files.each do |entry|
          if entry.name&.match?(get_xml_file_name_regex)
            yield entry.get_input_stream.read
          end
        end
      end
    end
  end

  def contains_pdf?
    download_blob_to_tempfile do |file|
      Zip::File.open(file.path) do |zipped_files|
        zipped_files.each do |entry|
          if entry.name&.match?(/.*\.pdf/)
            return true
          end
        end
      end
    end
  end

  def get_xml_file_name_regex
    /[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}.*\.xml/
  end

  def delete_notification_file
    notification_file = self.class.get_notification_file_from_blob(blob)
    notification_file.destroy
  end
end
