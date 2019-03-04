class AddUploadErrorToNotificationFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :notification_files, :upload_error, :string
  end
end
