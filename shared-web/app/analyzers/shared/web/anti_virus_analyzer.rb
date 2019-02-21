module Shared
  module Web
    class AntiVirusAnalyzer < ActiveStorage::Analyzer
      def initialize(blob)
        config = {
          daemonize: true,
          error_clamscan_missing: true,
          error_clamscan_client_error: true,
          error_file_missing: true,
          error_file_virus: false
        }
        config[:config_file] = "clamav/clamd.conf" if Rails.env.production?
        Clamby.configure(config)
        super(blob)
      end

      def self.accept?(_blob)
        true
      end

      def metadata
        download_blob_to_tempfile do |file|
          if Clamby.safe? file.path
            { safe: true }
          else
            Rails.logger.warn "#{@blob.id} detected as virus, removing."
            attachments = ActiveStorage::Attachment.where(blob_id: @blob.id)
            attachments.each(&:destroy)
            @blob.purge_later
            { safe: false }
          end
        end
      end
    end
  end
end
