class CreateNotificationDeleteLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :notification_delete_logs do |t|
      t.uuid :submit_user_id
      t.string :notification_product_name
      t.integer :responsible_person_id
      t.datetime :notification_created_at
      t.datetime :notification_updated_at
      t.string :cpnp_reference

      t.timestamps
      t.index :responsible_person_id
    end
  end
end
