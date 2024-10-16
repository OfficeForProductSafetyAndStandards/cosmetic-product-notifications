class AddNotificationIdToNanoMaterial < ActiveRecord::Migration[6.1]
  def change
    add_column :nano_materials, :notification_id, :integer
  end
end
