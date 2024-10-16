class AddReferenceNumberToNotificationDeleteLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :notification_delete_logs, :reference_number, :integer
  end
end
