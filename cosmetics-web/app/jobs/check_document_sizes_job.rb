# This job checks for documents that would be too large to index in OpenSearch
# It helps to proactively identify potential circuit breaker issues
class CheckDocumentSizesJob < ApplicationJob
  def perform
    Rails.logger.info "[Opensearch] Starting document size check job"

    large_notifications = find_large_notifications
    if large_notifications.any?
      Rails.logger.warn "[Opensearch] Found #{large_notifications.size} notifications that are too large to index properly"

      large_notifications.each do |notification|
        doc_size = calculate_document_size(notification)
        Rails.logger.warn "[Opensearch] Notification #{notification.id} (ref: #{notification.reference_number}) has document size of #{doc_size} bytes, " \
                        "which exceeds the limit of #{notification.maximum_document_size_bytes} bytes"
      end
    else
      Rails.logger.info "[Opensearch] No notifications found with excessive document sizes"
    end
  end

private

  def find_large_notifications
    # Check all completed and archived notifications
    large_docs = []

    Notification.opensearch.find_each do |notification|
      doc_size = calculate_document_size(notification)
      if doc_size > notification.maximum_document_size_bytes
        large_docs << notification
      end
    end

    large_docs
  end

  def calculate_document_size(notification)
    notification.as_indexed_json.to_json.bytesize
  end
end
