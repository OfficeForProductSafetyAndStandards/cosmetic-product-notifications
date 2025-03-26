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
    let(:file) { Tempfile.new("") }

    before do
      allow(analyzer).to receive(:download_blob_to_tempfile).and_yield(file)
    end

    context "when the antivirus does not detect a virus" do
      before do
        allow(RestClient::Request).to receive(:execute).and_return(
          instance_double(RestClient::Response, code: 200, body: '{"malware": false, "reason": null, "time": 0.001}'),
        )
      end

      it "sets as safe on the metadata" do
        expect(analyzer.metadata).to eq({ safe: true })
      end
    end

    context "when the antivirus detects a virus" do
      before do
        allow(RestClient::Request).to receive(:execute).and_return(
          instance_double(RestClient::Response, code: 200, body: '{"malware": true, "reason": "Eicar-Test-Signature", "time": 0.001}'),
        )
      end

      it "sets as not safe on the metadata with the reason" do
        expect(analyzer.metadata).to eq({ safe: false, message: "Eicar-Test-Signature" })
      end
    end

    context "when there is an error connecting to the antivirus service" do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(StandardError.new("Connection error"))
      end

      it "handles the error gracefully" do
        result = analyzer.metadata
        expect(result[:safe]).to be(false)
        expect(result[:error]).to eq("Connection error")
      end
    end

    context "when the file is missing or cannot be accessed" do
      let(:metadata_result) { { safe: false, error: "File not found" } }

      it "handles the missing file error" do
        allow(analyzer).to receive(:download_blob_to_tempfile).and_return(metadata_result)

        result = analyzer.metadata
        expect(result[:safe]).to be(false)
        expect(result[:error]).to eq("File not found")
      end
    end
  end

  describe ".accept?" do
    it "accepts all blobs" do
      expect(described_class.accept?(nil)).to be true
    end
  end
end
