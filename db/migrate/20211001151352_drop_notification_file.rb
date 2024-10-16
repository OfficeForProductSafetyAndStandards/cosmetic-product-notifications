class DropNotificationFile < ActiveRecord::Migration[6.1]
  def change
    drop_table :notification_files do |t|
      t.string :name
      t.string :upload_error
      t.timestamps null: false
      t.references :responsible_person, foreign_key: true, type: :bigint
      t.references :user, foreign_key: false, type: :uuid, index: false
    end
  end
end
