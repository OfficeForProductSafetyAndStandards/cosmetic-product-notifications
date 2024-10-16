class AddArchiveReasonToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :archive_reason, :string
  end
end
