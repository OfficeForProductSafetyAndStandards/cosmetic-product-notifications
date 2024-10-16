class AddDeletedAtToNotification < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :deleted_at, :datetime
  end
end
