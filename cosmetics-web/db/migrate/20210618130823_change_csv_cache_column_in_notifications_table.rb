class ChangeCsvCacheColumnInNotificationsTable < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_column :notifications, :csv_cache, :text
    end
  end
end
