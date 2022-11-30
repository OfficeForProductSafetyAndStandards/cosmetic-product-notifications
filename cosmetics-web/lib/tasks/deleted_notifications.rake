namespace :deleted_notifications do
  desc "Backfills the deleted_at column when missing for deleted notifications"
  task backfill_missing_deletion_timestamp: :environment do
    ActiveRecord::Base.transaction do
      Notification.where(state: "deleted").where(deleted_at: nil).find_each do |notification|
        notification.update_column(:deleted_at, notification.updated_at)
      end
    end
  end
end
