namespace :one_off do
  namespace :paper_trail_versions do
    desc "Migrate PaperTrail Versions to use more descriptive event names"
    # This task should only be run once, but there are no side effects of
    # running it multiple times
    task migrate: :environment do
      archive_count = PaperTrail::Version.where(event: "update").where("object ->> 'state' = 'archived'").count
      p "Migrating #{archive_count} versions to 'archive' event"
      PaperTrail::Version.where(event: "update").where("object ->> 'state' = 'archived'").update_all(event: "archive")

      unarchive_count = PaperTrail::Version.where(event: "update").where("object ->> 'state' = 'notification_complete'").count
      p "Migrating #{unarchive_count} versions to 'unarchive' event"
      PaperTrail::Version.where(event: "update").where("object ->> 'state' = 'notification_complete'").update_all(event: "unarchive")
    end
  end
end
