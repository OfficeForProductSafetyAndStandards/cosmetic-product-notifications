class AddNotificationCompleteAtToNotifications < ActiveRecord::Migration[5.2]
  # rubocop:disable Rails/ApplicationRecord
  class Notification < ActiveRecord::Base; end

  # rubocop:enable Rails/ApplicationRecord
  def up
    add_column :notifications, :notification_complete_at, :datetime, null: true
    Notification.reset_column_information
    Notification.where(state: :notification_complete).in_batches(of: 10_000) do |relation|
      relation.update_all("notification_complete_at = updated_at")
    end
  end

  def down
    remove_column :notifications, :notification_complete_at
  end
end
