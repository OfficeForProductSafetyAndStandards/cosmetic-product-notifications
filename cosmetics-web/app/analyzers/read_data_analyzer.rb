require 'zip'

class ReadDataAnalyzer < ActiveStorage::Analyzer
  def initialize(blob)
    super(blob)
  end

  def self.accept?(_blob)
    true
  end

  def metadata
    {notification_name: set_notification_from_file}
  end

  private

  def set_notification_from_file
    get_xml_file do |xml_file|
      xml_doc = Nokogiri::XML(xml_file.get_input_stream.read.gsub('sanco-xmlgate:', ''))
      notification_current_name = xml_doc.
          xpath('//currentVersion/generalInfo/productNameList/productName/name').first.text
      notification_current_name
    end
  end

  def get_xml_file
    download_blob_to_tempfile do |file|
      Zip::File.open(file.path) do |zip_file|
        yield zip_file.glob(get_xml_file_name_regex).first
      end
    end
  end

  def get_xml_file_name_regex
    return blob.filename.base[0...8]+'*.xml'
  end
end
