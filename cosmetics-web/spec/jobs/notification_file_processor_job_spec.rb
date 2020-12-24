require "rails_helper"

RSpec.describe NotificationFileProcessorJob, :with_stubbed_antivirus do
  after do
    sign_out(:submit_user)
    remove_uploaded_files
    close_file
  end

  let(:responsible_person) { create(:responsible_person) }

  describe "#perform" do
    subject(:job) { described_class.new }

    context "when the attached file is safe from virus" do
      let(:notification_file) do
        create(:notification_file, uploaded_file: uploaded_file)
      end

      before do
        allow(uploaded_file).to receive(:metadata).and_return({ "safe" => true })
      end

      context "with a valid zip file" do
        let(:uploaded_file) { create_file_blob("testExportFile.zip") }

        it "removes the notification file" do
          job.perform(notification_file.id)
          expect {
            notification_file.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "creates a notification populated with relevant name" do
          expect { job.perform(notification_file.id) }.to change(Notification, :count).by(1)
          notification = Notification.order(created_at: :asc).last
          expect(notification.product_name).equal?("CTPA moisture conditioner")
        end
      end

      context "when the file is the wrong file type" do
        let(:uploaded_file) { create_file_blob("testImage.png") }

        it "adds an error to the file" do
          job.perform(notification_file.id)
          expect(notification_file.reload.upload_error).to eq("uploaded_file_not_a_zip")
        end
      end

      context "when the zip files contains PDFs" do
        let(:uploaded_file) { create_file_blob("testZippedPDF.zip") }

        it "adds an error to the file" do
          job.perform(notification_file.id)
          expect(notification_file.reload.upload_error).to eq("unzipped_files_are_pdf")
        end
      end

      context "when the zip file does not contain a product XML file" do
        let(:uploaded_file) { create_file_blob("testNoProductFile.zip") }

        it "adds an error to the file" do
          job.perform(notification_file.id)
          expect(notification_file.reload.upload_error).to eq("product_file_not_found")
        end
      end

      context "when the zip file cannot be validated" do
        let(:uploaded_file) { create_file_blob("testExportWithMissingData.zip") }

        it "adds an error to the file" do
          job.perform(notification_file.id)
          expect(notification_file.reload.upload_error).to eq("notification_validation_error")
        end
      end

      context "when the zip file contains a draft notification" do
        let(:uploaded_file) { create_file_blob("testDraftNotification.zip") }

        it "adds an error to the file" do
          job.perform(notification_file.id)
          expect(notification_file.reload.upload_error).to eq("draft_notification_error")
        end
      end

      context "when a notification for that product already exists" do
        let(:uploaded_file) { create_file_blob("testExportFile.zip") }
        let(:notification_file) do
          create(:notification_file, uploaded_file: uploaded_file, responsible_person: responsible_person)
        end

        before do
          # create pre-existing duplicate notification
          create(:registered_notification, responsible_person: responsible_person, cpnp_reference: "1000094")
        end

        it "adds an error to the file" do
          job.perform(notification_file.id)
          expect(notification_file.reload.upload_error).to eq("notification_duplicated")
        end
      end

      context "when the zip files exceeds the file size limit" do
        let(:uploaded_file) { create_file_blob("testExportFile.zip") }

        before do
          stub_const("NotificationFile::MAX_FILE_SIZE_BYTES", 10)
        end

        it "adds an error to the file" do
          job.perform(notification_file.id)
          expect(notification_file.reload.upload_error).to eq("file_size_too_big")
        end
      end
    end

    context "when a virus has been detected in the attached file" do
      let(:uploaded_file) { create_file_blob("testExportFile.zip") }
      let(:notification_file) { create(:notification_file, uploaded_file: uploaded_file) }

      before do
        allow(uploaded_file).to receive(:metadata).and_return({ "safe" => false })
        # To be able to stub the metadata without being overriden on storage
        allow(NotificationFile).to receive(:find).and_return(notification_file)
      end

      # rubocop:disable RSpec/ExampleLength
      it "does not create a notification" do
        expect {
          begin
            job.perform(notification_file.id)
          rescue described_class::AntivirusCheckFailedError
            nil
          end
        }.not_to change(Notification, :count)
      end

      it "does not enqueue the job again" do
        ActiveJob::Base.queue_adapter = :test
        begin
          job.perform(notification_file.id)
        rescue described_class::AntivirusCheckFailedError
          nil
        end
        expect(described_class).not_to have_been_enqueued
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context "when the antivirus check has not run for the attached file" do
      let(:uploaded_file) { create_file_blob("testExportFile.zip") }
      let(:notification_file) { create(:notification_file, uploaded_file: uploaded_file) }

      before do
        allow(uploaded_file).to receive(:metadata).and_return({})
        # To be able to stub the metadata without being overriden on storage
        allow(NotificationFile).to receive(:find).and_return(notification_file)
      end

      # rubocop:disable RSpec/ExampleLength
      it "does not create a notification" do
        expect {
          begin
            job.perform(notification_file.id)
          rescue described_class::AntivirusCheckPendingError
            nil
          end
        }.not_to change(Notification, :count)
      end

      # Struggling to get this bit tested, as the "retry_on" magic does not seem to be happening on specs
      xit "enqueues the job again" do
        ActiveJob::Base.queue_adapter = :test
        begin
          job.perform(notification_file.id)
        rescue described_class::AntivirusCheckPendingError
          nil
        end
        expect(described_class).to have_been_enqueued
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
