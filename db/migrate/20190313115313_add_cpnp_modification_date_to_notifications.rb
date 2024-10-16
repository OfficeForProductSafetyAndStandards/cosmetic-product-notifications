class AddCpnpModificationDateToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :cpnp_notification_date, :datetime
  end
end
