class CopyImageUploadsJob < ApplicationJob
  include Sidekiq::Status::Worker

  def perform(old_notification_id, new_notification_id)
    NotificationCloner::ImageCloner.clone(notification(old_notification_id), notification(new_notification_id))
  end

private

  def notification(id)
    Notification.find id
  end
end
