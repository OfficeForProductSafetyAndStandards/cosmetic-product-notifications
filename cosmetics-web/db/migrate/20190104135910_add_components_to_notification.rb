class AddComponentsToNotification < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :components, :notification, index: false, foreign_key: true
    add_index :components, :notification_id, algorithm: :concurrently
  end
end
