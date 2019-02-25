module AnalyzerHelper
  def get_notification_file_from_blob(blob)
    ::NotificationFile.find_by(id: blob.attachments.first.record_id)
  end
end
