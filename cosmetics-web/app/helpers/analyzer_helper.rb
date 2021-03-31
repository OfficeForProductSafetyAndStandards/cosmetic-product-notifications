module AnalyzerHelper
  def get_notification_file_from_blob(blob)
    record_id = blob&.attachments&.first&.record_id
    return if record_id.blank?

    ::NotificationFile.find_by(id: record_id)
  end
end
