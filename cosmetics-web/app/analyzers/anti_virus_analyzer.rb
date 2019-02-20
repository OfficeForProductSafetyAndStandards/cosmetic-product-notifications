class AntiVirusAnalyzer < Shared::Web::AntiVirusAnalyzer
  include AnalyzerHelper

  def metadata
    download_blob_to_tempfile do |file|
      if Clamby.safe? file.path
        { safe: true }
      else
        Rails.logger.warn "#{@blob.id} detected as virus, removing."
        notification_file = get_notification_file_from_blob(@blob)
        notification_file.update(upload_error: :file_flagged_as_virus)
        attachments = ActiveStorage::Attachment.where(blob_id: @blob.id)
        attachments.each(&:destroy)
        @blob.purge_later
        { safe: false }
      end
    end
  end
end
