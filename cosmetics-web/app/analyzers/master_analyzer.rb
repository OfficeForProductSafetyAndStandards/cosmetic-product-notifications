class MasterAnalyzer < ActiveStorage::Analyzer
  def self.accept?(_blob)
    true
  end

  # Collect metadata from all of the other analyzers to add to the blob
  def metadata
    Rails.application.config.document_analyzers.each do |analyzer_class|
      if analyzer_class.accept? @blob
        analyzer = analyzer_class.new @blob
        @blob.metadata.merge!(analyzer.metadata)
      end
    end
    @blob.metadata
  end
end
