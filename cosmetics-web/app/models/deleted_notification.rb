class DeletedNotification < ApplicationRecord
  belongs_to :notification

  def recover!
    transaction do
      Notification::DELETABLE_ATTRIBUTES.each do |field|
        notification[field] = self[field]
      end
      notification.deleted_at = nil
      notification.state = self[:state]
      notification.paper_trail_event = "undelete"
      notification.paper_trail.save_with_version(validate: false)

      notification.index_document

      self.delete # rubocop:disable Style/RedundantSelf
    end
  end
end
