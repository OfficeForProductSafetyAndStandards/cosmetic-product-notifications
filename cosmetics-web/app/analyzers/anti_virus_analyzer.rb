class AntiVirusAnalyzer < Shared::Web::AntiVirusAnalyzer
  include AnalyzerHelper

  def metadata
    notification_file = get_notification_file_from_blob(@blob)
    metadata = super

    if metadata["safe"] == false && notification_file.present?
      notification_file.update(upload_error: :file_flagged_as_virus)
    end

    metadata
  end
end
