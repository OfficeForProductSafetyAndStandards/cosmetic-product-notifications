require 'zip'

class ReadDataAnalyzer < ActiveStorage::Analyzer
  def initialize(blob)
    super(blob)
  end

  def self.accept?(_blob)
    true
  end

  def metadata
    get_xml_file do |xml_file|
      puts xml_file.get_input_stream.read
    end
    {zip: 2}
  end

  private

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
