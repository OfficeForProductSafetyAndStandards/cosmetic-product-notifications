class CopyImageUploadsJob < ApplicationJob
  include Sidekiq::Status::Worker

  def perform(old_notification_id, new_notification_id)
    NotificationCloner::ImageCloner.clone(notification(old_notification_id), notification(new_notification_id))
  end

  def expiration
    @expiration ||= 60 * 60 * 24 * 30 # 30 days
  end

private

  def notification(id)
    Notification.find id
  end
end
