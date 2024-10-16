class AddCsvCacheToNotifications < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :notifications, :csv_cache, :json
    end
  end
end
