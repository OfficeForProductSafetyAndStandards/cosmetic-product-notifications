class ChangeCsvCacheColumnInNotificationsTable < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      # rubocop:disable Rails/ReversibleMigration
      change_column :notifications, :csv_cache, :text
      # rubocop:enable Rails/ReversibleMigration
    end
  end
end
