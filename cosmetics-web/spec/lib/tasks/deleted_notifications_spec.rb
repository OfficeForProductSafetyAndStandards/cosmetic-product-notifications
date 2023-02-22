require "rails_helper"
Rails.application.load_tasks

# rubocop:disable RSpec/DescribeClass
RSpec.describe "deleted_notifications.rake" do
  describe "backfill_missing_deletion_timestamp" do
    subject(:task) { Rake::Task["deleted_notifications:backfill_missing_deletion_timestamp"] }

    let(:creation_time) { Time.zone.local(2022, 10, 30, 14) }
    let(:deletion_time) { Time.zone.local(2022, 10, 30, 15) }

    let!(:deleted_notification) do
      create(:notification, :deleted, deleted_at: nil, updated_at: deletion_time, created_at: creation_time)
    end

    after do
      # Rake tasks only run on the first invocation per suite. This re-enables the task for the next test.
      task.reenable
    end

    it "sets the deletion timestampt to the last time the notification got updated" do
      expect { task.invoke }.to change { deleted_notification.reload.deleted_at }.from(nil).to(deletion_time)
    end

    it "does not update the updated_at time" do
      expect { task.invoke }.not_to(change { deleted_notification.reload.updated_at })
    end

    it "does not change notifications that already have a deletion timestamp" do
      deleted_notification.update!(deleted_at: creation_time + 1.hour)
      expect { task.invoke }.not_to(change { deleted_notification.reload.deleted_at })
    end
  end
end
# rubocop:enable RSpec/DescribeClass
