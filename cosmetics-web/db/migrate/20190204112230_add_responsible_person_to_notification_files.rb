class AddResponsiblePersonToNotificationFiles < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :notification_files, :responsible_person, foreign_key: true, index: false
    add_index :notification_files, :responsible_person_id, algorithm: :concurrently

    add_column :notification_files, :user_id, :string
  end
end
