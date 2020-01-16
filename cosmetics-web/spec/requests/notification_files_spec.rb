require "rails_helper"

RSpec.describe "Notification files", :with_stubbed_antivirus, type: :request do
  after do
    sign_out
  end

  context "when signed in as a user of a responsible_person" do
    let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
    let(:user) { build(:user) }
    let(:colleague) { build(:user) }

    before do
      sign_in_as_member_of_responsible_person(responsible_person, user)
    end

    context "when deleting a notification file" do
      let(:notification_file) { create(:notification_file, responsible_person: responsible_person, user: user) }

      before do
        delete responsible_person_notification_file_path(responsible_person, notification_file)
      end

      it "redirects to the notifications dashboard" do
        expect(response).to redirect_to(responsible_person_notifications_path(responsible_person))
      end

      it "deletes the notification file" do
        expect { notification_file.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when deleting ALL notification files with errors" do
      let!(:notification_file_with_error_1) { create(:notification_file, responsible_person: responsible_person, user: user, upload_error: "uploaded_file_not_a_zip") }
      let!(:notification_file_with_error_2) { create(:notification_file, responsible_person: responsible_person, user: user, upload_error: "uploaded_file_not_a_zip") }
      let!(:notification_file_with_no_error) { create(:notification_file, responsible_person: responsible_person, user: user, upload_error: nil) }
      let!(:notification_file_with_error_belonging_to_colleague) { create(:notification_file, responsible_person: responsible_person, user: colleague, upload_error: "uploaded_file_not_a_zip") }


      before do
        delete destroy_all_responsible_person_notification_files_path(responsible_person)
      end

      it "redirects to the notifications dashboard" do
        expect(response).to redirect_to(responsible_person_notifications_path(responsible_person))
      end

      it "deletes the notification files with errors" do
        expect { notification_file_with_error_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { notification_file_with_error_2.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "does not delete the notification file with no error" do
        expect { notification_file_with_no_error.reload }.not_to raise_error
      end

      it "does not delete the notification file belonging to a colleague" do
        expect { notification_file_with_error_belonging_to_colleague.reload }.not_to raise_error
      end
    end
  end
end
