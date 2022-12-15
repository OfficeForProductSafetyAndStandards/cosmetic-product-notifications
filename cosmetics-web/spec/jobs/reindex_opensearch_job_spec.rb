require "rails_helper"

RSpec.describe ReindexOpensearchJob do
  after do
    # Ensure no testing indices are left behind
    existing_indices = Elasticsearch::Model.client.indices.get(index: "*test*").keys.join(",")
    if existing_indices.present?
      Elasticsearch::Model.client.indices.delete(index: existing_indices, ignore_unavailable: true)
    end
  end

  # rubocop:disable RSpec/MultipleExpectations
  describe "#perform" do
    let(:execution_time) { Time.zone.local(2022, 12, 1, 13, 10, 45) }
    let(:new_index) { "#{Notification.index_name}_20221201131045" }

    let(:previous_execution_time) { Time.zone.local(2020, 11, 28, 14, 11, 55) }
    let(:original_index) { "#{Notification.index_name}_20201128141155" }

    before do
      # Sets up original index with a notification prior to reindexing
      travel_to previous_execution_time do
        create(:notification, :registered)
        Notification.import_to_opensearch
      end
      travel_to execution_time
      allow(Sidekiq.logger).to receive(:info)
    end

    context "when the reindexing is successful" do
      it "reindexes the notifications into a new index and deletes the original" do
        described_class.perform_now

        # Reindexed the notification into a new index
        expect(Notification.current_index).not_to eq(original_index)
        expect(Notification.index_docs_count).to eq 1

        # Deleted the original index
        expect(Notification.__elasticsearch__.client.indices.exists?(index: original_index)).to be false
      end

      it "logs the start of the reindexing" do
        described_class.perform_now

        expect(Sidekiq.logger)
          .to have_received(:info)
          .with("[NotificationIndex] Reindexing Opensearch Notification from #{original_index} index to #{new_index} index")
      end

      it "logs the success of the reindexing" do
        described_class.perform_now

        expect(Sidekiq.logger)
          .to have_received(:info)
          .with("[NotificationIndex] Reindexing Opensearch Notification from #{original_index} index to #{new_index} index succeeded")
      end
    end

    context "when the reindexing fails" do
      before do
        allow(Notification).to receive(:import).and_return(1) # 1 error found during import process
      end

      it "keeps the original index" do
        expect { described_class.perform_now }.not_to(
          change { Notification.__elasticsearch__.client.indices.get(index: "_all").keys.size },
        )
        # Kept the original index
        expect(Notification.current_index).to eq(original_index)
        expect(Notification.index_docs_count).to eq 1
      end

      it "logs the start of the reindexing" do
        described_class.perform_now

        expect(Sidekiq.logger)
          .to have_received(:info)
          .with("[NotificationIndex] Reindexing Opensearch Notification from #{original_index} index to #{new_index} index")
      end

      it "logs the failure of the reindexing" do
        described_class.perform_now

        expect(Sidekiq.logger)
          .to have_received(:info)
          .with("[NotificationIndex] Reindexing Opensearch Notification from #{original_index} index to #{new_index} index failed with 1 errors while importing")
      end
    end
  end
  # rubocop:enable RSpec/MultipleExpectations
end
