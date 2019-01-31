require 'zip'

class ReadDataAnalyzer < ActiveStorage::Analyzer
  def initialize(blob)
    super(blob)
  end

  def self.accept?(_blob)
    true
  end

  def metadata
    create_notification_from_file
    delete_notification_file
    {}
  end

private

  def create_notification_from_file
    @notification = Notification.new(product_name: get_notification_current_name,
                                     state: :draft_complete)
    @notification.save
  end

  def get_notification_current_name
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
    blob.filename.base[0...8] + '*.xml'
  end

  def delete_notification_file
    attachment = ActiveStorage::Attachment.find_by(blob_id: blob.id)
    notification_file = NotificationFile.find_by(id: attachment.record_id)
    notification_file.destroy
  end
end
