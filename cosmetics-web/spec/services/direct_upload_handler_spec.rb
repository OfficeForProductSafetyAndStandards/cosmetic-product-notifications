require "rails_helper"

RSpec.describe DirectUploadHandler, :with_stubbed_antivirus, :with_test_queue_adapter do
  let(:responsible_person) { create(:responsible_person) }
  let(:direct_upload_handler) { described_class.new(signed_ids, uploaded_file_names, responsible_person.id, submit_user.id) }
  let(:uploaded_file_names) { [filename1, filename2] }
  let(:submit_user) { create(:submit_user) }
  let(:filename1) { "testExportWithComponentWithPHRange.zip" }
  let(:filename2) { "testExportWithComponentWithSinglePHValue.zip" }
  let(:blob1) { ActiveStorage::Blob.create_after_upload!(filename: filename1, io: File.open(File.join("spec", "fixtures", filename1))) }
  let(:blob2) { ActiveStorage::Blob.create_after_upload!(filename: filename2, io: File.open(File.join("spec", "fixtures", filename2))) }

  before do
    create(:responsible_person_user, user: submit_user, responsible_person: responsible_person)
  end

  describe "success" do
    let(:signed_ids) { [blob1, blob2].map(&:signed_id) }

    it "creates NotificationFile records" do
      expect {
        direct_upload_handler.call
      }.to change(NotificationFile, :count).from(0).to(2)
    end

    it "creates NotificationFile with proper attachments" do
      direct_upload_handler.call

      expect(NotificationFile.first.uploaded_file.blob).to eq(blob1)
      expect(NotificationFile.last.uploaded_file.blob).to eq(blob2)
    end

    it "schedules notification file parsing" do
      allow(NotificationFileProcessorJob).to receive(:perform_later) { NotificationFile.first.id }
      allow(NotificationFileProcessorJob).to receive(:perform_later) { NotificationFile.last.id }

      direct_upload_handler.call
    end
  end

  describe "when one file is missing" do
    let(:signed_ids) { [blob1.signed_id, "blob2"] }

    it "creates NotificationFile records" do
      expect {
        direct_upload_handler.call
      }.to change(NotificationFile, :count).from(0).to(2)
    end

    it "creates one NotificationFile with proper attachments" do
      direct_upload_handler.call

      expect(NotificationFile.first.uploaded_file.attachment.blob).to eq(blob1)
      expect(NotificationFile.last.uploaded_file.attachment).to eq(nil)
    end

    it "creates one NotificationFile with proper error" do
      direct_upload_handler.call

      expect(NotificationFile.last.upload_error).to eq("file_upload_failed")
      expect(NotificationFile.last.name).to eq(File.basename(filename2, ".*"))
    end

    it "schedules only one notification file parsing" do
      allow(NotificationFileProcessorJob).to receive(:perform_later) { NotificationFile.first.id }

      direct_upload_handler.call
    end
  end
end
