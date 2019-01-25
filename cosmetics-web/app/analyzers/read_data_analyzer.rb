class ReadDataAnalyzer < ActiveStorage::Analyzer
  def self.accept?(_blob)
    true
  end

  def metadata
    download_blob_to_tempfile do |file|
      {analyzed: true}
    end
  end
end
