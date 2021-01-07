require "rails_helper"

RSpec.describe MasterAnalyzer, type: :analyzer, without_default_file_analyzers: true do
  subject(:analyzer) { described_class.new(blob) }

  describe "#metadata" do
    context "with a notification file" do
      let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testExportFile.zip")) }
      let(:blob) { notification_file.uploaded_file }

      context "when there is an error downloading the file", :with_stubbed_s3_returning_not_found do
        before { Rails.application.config.document_analyzers.append AntiVirusAnalyzer }

        it "sets an error on the notification file record" do
          expect { analyzer.metadata }.to change { notification_file.reload.upload_error }.from(nil).to("file_upload_failed")
        end
      end

      it "schedules NotificationFileProcessorJob" do
        allow(NotificationFileProcessorJob).to receive(:perform_later)
        analyzer.metadata
        expect(NotificationFileProcessorJob).to have_received(:perform_later).with(notification_file.id)
      end
    end
  end
end
