require "rails_helper"

RSpec.describe AntiVirusAnalyzer, type: :analyzer do
  describe "#metadata" do
    let(:analyzer) { described_class.new(blob) }
    let(:notification_file) { create(:notification_file) }
    let(:blob) do
      ActiveStorage::Blob.create_after_upload!(
        io: File.open(Rails.root.join("spec/fixtures/testImage.png"), "rb"),
        filename: "testImage.png",
        content_type: "image/png",
      )
    end

    before do
      allow(analyzer).to receive(:get_notification_file_from_blob).and_return(notification_file)
    end

    context "when the antivirus does not detect a virus", :with_stubbed_antivirus do
      it "sets as not safe on the metadata" do
        expect(analyzer.metadata).to eq({ safe: true })
      end
    end

    context "when the antivirus detects a virus", :with_stubbed_antivirus_returning_false do
      it "sets as safe on the metadata" do
        expect(analyzer.metadata).to eq({ safe: false })
      end

      it "adds an upload error on the notification file" do
        expect { analyzer.metadata }.to change(notification_file, :upload_error)
                                    .from(nil)
                                    .to("file_flagged_as_virus")
      end
    end
  end
end
