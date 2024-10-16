require "rails_helper"

RSpec.describe AntiVirusAnalyzer, type: :analyzer do
  describe "#metadata" do
    let(:analyzer) { described_class.new(blob) }
    let(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join("spec/fixtures/files/testImage.png"), "rb"),
        filename: "testImage.png",
        content_type: "image/png",
      )
    end

    context "when the antivirus does not detect a virus", :with_stubbed_antivirus do
      it "sets as safe on the metadata" do
        expect(analyzer.metadata).to eq({ safe: true })
      end
    end

    context "when the antivirus detects a virus", :with_stubbed_antivirus_returning_false do
      it "sets as not safe on the metadata" do
        expect(analyzer.metadata).to eq({ safe: false })
      end
    end
  end
end
