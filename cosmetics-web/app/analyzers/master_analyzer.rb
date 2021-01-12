class MasterAnalyzer < ActiveStorage::Analyzer
  include AnalyzerHelper

  def self.accept?(_blob)
    true
  end

  # Collect metadata from all of the other analyzers to add to the blob
  def metadata
    notification_file = get_notification_file_from_blob(@blob)

    begin
      Rails.application.config.document_analyzers.each do |analyzer_class|
        if analyzer_class.accept? @blob
          analyzer = analyzer_class.new @blob
          @blob.metadata.merge!(analyzer.metadata)
        end
      end
    rescue Aws::S3::Errors::NotFound
      notification_file.update(upload_error: :file_upload_failed) if notification_file.present?
    end

    # Process notification file only after analysing is complete
    NotificationFileProcessorJob.perform_later(notification_file.id) if notification_file.present?

    @blob.metadata
  end
end
