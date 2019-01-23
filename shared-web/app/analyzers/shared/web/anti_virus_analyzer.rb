module Shared
  module Web
    class AntiVirusAnalyzer < ActiveStorage::Analyzer
      def initialize(blob)
        config = { daemonize: true }
        config[:config_file] = "clamav/clamd.conf" if Rails.env.production?
        Clamby.configure(config)
        super(blob)
      end

      def self.accept?(_blob)
        true
      end

      def metadata
        download_blob_to_tempfile do |file|
          is_safe = Clamby.safe? file.path
          purge_blob unless is_safe
          { safe: is_safe }
        end
      end

    private

      def purge_blob
        attachments = ActiveStorage::Attachment.where(blob_id: @blob.id)
        attachments.each(&:destroy)
        @blob.purge
      end
    end
  end
end
