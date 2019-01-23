class CreateNotificationFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :notification_files do |t|
      t.string :name

      t.timestamps
    end
  end
end
