class AddNotNullConstraintToNotificationIdInComponents < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_column_null :components, :notification_id, false
    end
  end
end
