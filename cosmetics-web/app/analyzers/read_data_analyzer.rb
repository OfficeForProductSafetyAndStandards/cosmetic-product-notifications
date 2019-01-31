class ReadDataAnalyzer < ActiveStorage::Analyzer
  def initialize(blob)
    super(blob)
  end

  def self.accept?(_blob)
    true
  end

  def metadata
    ParseZipJob.perform_later(blob.id)
    {}
  end
end
