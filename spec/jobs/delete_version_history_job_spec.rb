require "rails_helper"

RSpec.describe DeleteVersionHistoryJob do
  let!(:notification) { create(:registered_notification, archive_reason: "significant_change_to_the_formulation") }

  before do
    Notification.import_to_opensearch(force: true)
  end

  # rubocop:disable RSpec/ExampleLength
  it "deletes version history older than seven years" do
    with_versioning do
      travel(-8.years) do
        notification.archive
      end

      notification.unarchive
    end

    expect(notification.reload.versions.count).to eq(2)

    described_class.perform_now

    expect(notification.versions.count).to eq(1)
  end
  # rubocop:enable RSpec/ExampleLength
end
