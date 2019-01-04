class AddImagesToNotification < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  
  def change
    add_reference :image_files, :notification, index: false, foreign_key: true
    add_index :image_files, :notification_id, algorithm: :concurrently
  end
end
