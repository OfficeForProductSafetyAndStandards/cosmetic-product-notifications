require "rails_helper"

RSpec.describe "Notification files", :with_stubbed_antivirus, type: :request do
  context "when signed in as a user of a responsible_person" do
    let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
    let(:user) { build(:submit_user) }
    let(:colleague) { build(:submit_user) }

    before do
      sign_in_as_member_of_responsible_person(responsible_person, user)
    end

    after do
      sign_out(:submit_user)
    end

    describe "deleting a notification file" do
      let(:notification_file) do
        create(:notification_file,
               uploaded_file: create_file_blob("testExportFile.zip"),
               responsible_person: responsible_person,
               user: user)
      end

      it "redirects to the notifications dashboard" do
        delete responsible_person_notification_file_path(responsible_person, notification_file)
        expect(response).to redirect_to(responsible_person_notifications_path(responsible_person))
      end

      it "deletes the notification file" do
        expect(notification_file).not_to be_nil
        delete responsible_person_notification_file_path(responsible_person, notification_file)
        expect { notification_file.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "deletes the notification file attachment" do
        attachment = notification_file.uploaded_file
        expect(attachment).not_to be_nil
        delete responsible_person_notification_file_path(responsible_person, notification_file)
        expect { attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "deletes the notification file blob" do
        blob = notification_file.uploaded_file.blob
        expect(blob).not_to be_nil
        delete responsible_person_notification_file_path(responsible_person, notification_file)
        expect { blob.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "deleting ALL notification files with errors" do
      let!(:notification_file_with_no_error) do
        create(:notification_file,
               responsible_person: responsible_person,
               uploaded_file: create_file_blob("testExportFile.zip"),
               user: user,
               upload_error: nil)
      end
      let!(:notification_file_with_error) do
        create(:notification_file,
               responsible_person: responsible_person,
               user: user,
               uploaded_file: create_file_blob("testExportFile.zip"),
               upload_error: "uploaded_file_not_a_zip")
      end
      let!(:notification_file2_with_error) do
        create(:notification_file,
               responsible_person: responsible_person,
               user: user,
               uploaded_file: create_file_blob("testExportFile.zip"),
               upload_error: "uploaded_file_not_a_zip")
      end
      let!(:notification_file_with_error_belonging_to_colleague) do
        create(:notification_file,
               responsible_person: responsible_person,
               uploaded_file: create_file_blob("testExportFile.zip"),
               user: colleague,
               upload_error: "uploaded_file_not_a_zip")
      end

      it "redirects to the notifications dashboard" do
        delete destroy_all_responsible_person_notification_files_path(responsible_person)
        expect(response).to redirect_to(responsible_person_notifications_path(responsible_person))
      end

      it "deletes the notification files with errors belonging to the user" do
        delete destroy_all_responsible_person_notification_files_path(responsible_person)
        expect(responsible_person.notification_files).to contain_exactly(
          notification_file_with_no_error,
          notification_file_with_error_belonging_to_colleague,
        )
      end

      it "deletes the attachments from the deleted notification files" do
        attachment = notification_file_with_error.uploaded_file.attachment
        attachment2 = notification_file2_with_error.uploaded_file.attachment

        delete destroy_all_responsible_person_notification_files_path(responsible_person)
        expect { attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { attachment2.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "deletes the attachment blobs from the deleted notification files" do
        blob = notification_file_with_error.uploaded_file.blob
        blob2 = notification_file2_with_error.uploaded_file.blob

        delete destroy_all_responsible_person_notification_files_path(responsible_person)
        expect { blob.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { blob2.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
