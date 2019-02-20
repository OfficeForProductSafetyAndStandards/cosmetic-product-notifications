require 'zip'

class ReadDataAnalyzer < ActiveStorage::Analyzer
  extend AnalyzerHelper

  def initialize(blob)
    super(blob)
  end

  def self.accept?(given_blob)
    return false if given_blob.blank?

    # this analyzer only accepts notification files which are zip
    notification_file = get_notification_file_from_blob(given_blob)

    notification_file.present?
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
      @xml_info = CPNPExport.new(xml_file_content)
    end

    notification = ::Notification.new(product_name: @xml_info.product_name,
                                       cpnp_reference: @xml_info.cpnp_reference,
                                       cpnp_is_imported: @xml_info.is_imported,
                                       cpnp_imported_country: @xml_info.imported_country,
                                       shades: @xml_info.shades,
                                       components: @xml_info.components,
                                       responsible_person: notification_file.responsible_person)
    notification.notification_file_parsed!
    notification.save
  end

  def get_xml_file_content
    download_blob_to_tempfile do |file|
      Zip::File.open(file.path) do |zip_file|
        zip_file.each do |entry|
          if entry.name&.match?(get_xml_file_name_regex)
            yield entry.get_input_stream.read
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
