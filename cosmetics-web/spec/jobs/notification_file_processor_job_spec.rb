require "rails_helper"

RSpec.describe NotificationFileProcessorJob, :with_stubbed_antivirus do
  after do
    sign_out(:submit_user)
    remove_uploaded_files
    close_file
  end

  let(:responsible_person) { create(:responsible_person) }

  describe "#perform" do
    before do
      described_class.new.perform(notification_file.id)
    end

    context "with a valid zip file" do
      let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testExportFile.zip")) }

      it "removes the notification file" do
        expect {
          notification_file.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "creates a notification populated with relevant name" do
        notification = Notification.order(created_at: :asc).last
        expect(notification.product_name).equal?("CTPA moisture conditioner")
      end
    end

    context "when the file is the wrong file type" do
      let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testImage.png")) }

      it "adds an error to the file" do
        expect(notification_file.reload.upload_error).to eq("uploaded_file_not_a_zip")
      end
    end

    context "when the zip files contains PDFs" do
      let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testZippedPDF.zip")) }

      it "adds an error to the file" do
        expect(notification_file.reload.upload_error).to eq("unzipped_files_are_pdf")
      end
    end

    context "when the zip file does not contain a product XML file" do
      let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testNoProductFile.zip")) }

      it "adds an error to the file" do
        expect(notification_file.reload.upload_error).to eq("product_file_not_found")
      end
    end

    context "when the zip file cannot be validated" do
      let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testExportWithMissingData.zip")) }

      it "adds an error to the file" do
        expect(notification_file.reload.upload_error).to eq("notification_validation_error")
      end
    end

    context "when the zip file contains a draft notification" do
      let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testDraftNotification.zip")) }

      it "adds an error to the file" do
        expect(notification_file.reload.upload_error).to eq("draft_notification_error")
      end
    end
  end

  context "when a notification for that product already exists" do
    let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testExportFile.zip"), responsible_person: responsible_person) }

    before do
      # create pre-existing duplicate notification
      create(:registered_notification, responsible_person: responsible_person, cpnp_reference: "1000094")

      described_class.new.perform(notification_file.id)
    end

    it "adds an error to the file" do
      expect(notification_file.reload.upload_error).to eq("notification_duplicated")
    end
  end

  context "when the zip files exceeds the file size limit" do
    let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testExportFile.zip")) }

    before do
      stub_const("NotificationFile::MAX_FILE_SIZE_BYTES", 10)
      described_class.new.perform(notification_file.id)
    end

    it "adds an error to the file" do
      expect(notification_file.reload.upload_error).to eq("file_size_too_big")
    end
  end

  context "when there is an unexpected error parsing the files" do
    let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testExportFile.zip")) }
    let(:exception) { StandardError.new }

    before do
      allow(Zip::File).to receive(:open).and_raise(exception)
      allow(Raven).to receive(:capture_exception)
      described_class.new.perform(notification_file.id)
    end

    it "does not remove the notification file" do
      expect {
        notification_file.reload
      }.not_to raise_error(ActiveRecord::RecordNotFound)
    end

    it "adds an error to the file" do
      expect(notification_file.reload.upload_error).to eq("unknown_error")
    end

    it "sends the error to Sentry" do
      expect(Raven).to have_received(:capture_exception).once.with(exception)
    end
  end
end
