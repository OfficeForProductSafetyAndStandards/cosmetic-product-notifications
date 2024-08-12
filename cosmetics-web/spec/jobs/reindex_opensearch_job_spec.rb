require "rails_helper"

RSpec.describe ReindexOpensearchJob do
  after do
    existing_indices = Elasticsearch::Model.client.indices.get(index: "*test*").keys.join(",")
    if existing_indices.present?
      Elasticsearch::Model.client.indices.delete(index: existing_indices, ignore_unavailable: true)
    end
  end

  describe "#perform" do
    let(:execution_time) { Time.zone.local(2022, 12, 1, 13, 10, 45) }
    let(:previous_execution_time) { Time.zone.local(2020, 11, 28, 14, 11, 55) }

    before do
      # Set up original index with a notification prior to reindexing
      travel_to previous_execution_time do
        create(:notification, :registered)
        Notification.import_to_opensearch
      end
      travel_to execution_time
      allow(Sidekiq.logger).to receive(:info)
    end

    context "when the reindexing is successful" do
      it "changes the index to a new one" do
        original_index = Notification.current_index

        described_class.perform_now

        new_index = Notification.current_index

        expect(new_index).not_to eq(original_index)
      end

      it "has one document in the new index" do
        described_class.perform_now

        expect(Notification.index_docs_count).to eq 1
      end

      it "deletes the original index" do
        original_index = Notification.current_index

        described_class.perform_now

        expect(Notification.__elasticsearch__.client.indices.exists?(index: original_index)).to be false
      end

      it "logs the start of the reindexing" do
        original_index = Notification.current_index

        described_class.perform_now

        new_index = "#{Notification.index_name}_#{execution_time.strftime('%Y%m%d%H%M%S')}"

        expect(Sidekiq.logger)
          .to have_received(:info)
          .with("[Opensearch] [NotificationIndex] Reindexing Opensearch Notification from #{original_index} index to #{new_index} index")
      end

      it "logs the success of the reindexing" do
        original_index = Notification.current_index

        described_class.perform_now

        new_index = "#{Notification.index_name}_#{execution_time.strftime('%Y%m%d%H%M%S')}"

        expect(Sidekiq.logger)
          .to have_received(:info)
          .with("[Opensearch] [NotificationIndex] Reindexing Opensearch Notification from #{original_index} index to #{new_index} index succeeded")
      end
    end

    context "when the reindexing fails" do
      before do
        allow(Notification).to receive(:import).and_return(1) # 1 error found during import process
      end

      it "logs the start of the reindexing" do
        original_index = Notification.current_index

        described_class.perform_now

        new_index = "#{Notification.index_name}_#{execution_time.strftime('%Y%m%d%H%M%S')}"

        expect(Sidekiq.logger)
          .to have_received(:info)
          .with("[Opensearch] [NotificationIndex] Reindexing Opensearch Notification from #{original_index} index to #{new_index} index")
      end

      it "logs the failure of the reindexing" do
        original_index = Notification.current_index

        described_class.perform_now

        new_index = "#{Notification.index_name}_#{execution_time.strftime('%Y%m%d%H%M%S')}"

        expect(Sidekiq.logger)
          .to have_received(:info)
          .with("[Opensearch] [NotificationIndex] Reindexing Opensearch Notification from #{original_index} index to #{new_index} index failed with 1 errors while importing")
      end
    end
  end
end
