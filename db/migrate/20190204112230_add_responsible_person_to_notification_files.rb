class AddResponsiblePersonToNotificationFiles < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :notification_files, :responsible_person, foreign_key: true, index: true

      add_column :notification_files, :user_id, :string
    end
  end
end
