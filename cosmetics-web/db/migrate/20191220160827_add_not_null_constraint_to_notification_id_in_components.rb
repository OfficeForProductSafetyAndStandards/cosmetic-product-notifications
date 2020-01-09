class AddNotNullConstraintToNotificationIdInComponents < ActiveRecord::Migration[5.2]
  def change
    change_column_null :components, :notification_id, false
  end
end
