module Shared
  module Web
    class MasterAnalyzer < ActiveStorage::Analyzer
      def self.accept?(_blob)
        true
      end

      # Collect metadata from all of the other analyzers to add to the blob
      def metadata
        analyzers.collect(&:metadata)
            .reduce(:merge)
      end

    private

      def analyzers
        Rails.application.config.document_analyzers
            .select { |analyzer_class| analyzer_class.accept? @blob }
            .collect { |analyzer_class| analyzer_class.new(@blob) }
      end
    end
  end
end
