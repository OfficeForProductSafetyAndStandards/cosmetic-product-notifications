class AddSourceNotificationIdToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :source_notification_id, :integer
  end
end
