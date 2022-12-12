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
    let(:original_index) { Notification.current_index }

    before do
      # Sets up original index prior to reindexing
      create(:notification, :registered)
      travel_to 1.day.ago do
        Notification.import_to_opensearch
      end
      original_index
    end

    it "reindexes the notifications into a new index and deletes the original index" do
      described_class.perform_now

      # Reindexed the notification into a new index
      expect(Notification.current_index).not_to eq(original_index)
      expect(Notification.index_docs_count).to eq 1

      # Deleted the original index
      expect(Notification.__elasticsearch__.client.indices.exists?(index: original_index)).to be false
    end

    it "keeps the original index if the reindexing fails" do
      allow(Notification).to receive(:import).and_return(1) # 1 error found during import process

      expect { described_class.perform_now }.not_to(
        change { Notification.__elasticsearch__.client.indices.get(index: "_all").keys.size },
      )
      # Kept the original index
      expect(Notification.current_index).to eq(original_index)
      expect(Notification.index_docs_count).to eq 1
    end
  end
  # rubocop:enable RSpec/MultipleExpectations
end
