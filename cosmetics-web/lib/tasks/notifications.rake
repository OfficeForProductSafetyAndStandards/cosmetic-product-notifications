namespace :notifications do
  # One off task as part of the removal of Notification ZIP upload flow.
  # Remove after running it.
  desc "Migrate notifications state from 'notification_file_imported' to 'draft_complete'"
  task migrate_file_imported_state: :environment do
    Notification.where(state: :notification_file_imported).update_all(state: :draft_complete)
  end
end
