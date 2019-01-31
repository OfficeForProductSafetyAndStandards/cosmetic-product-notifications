require 'zip'

class ParseZipJob < ApplicationJob

  include ActiveStorage::Downloading

  attr_reader :blob

  def perform(blob_id)
    @blob = ActiveStorage::Blob.find_by(id: blob_id)
    create_notification
  end

  private

  def create_notification
    @notification = Notification.new(product_name: get_notification_current_name_from_file)
    @notification.save
  end

  def get_notification_current_name_from_file
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
    return @blob.filename.base[0...8]+'*.xml'
  end
end
