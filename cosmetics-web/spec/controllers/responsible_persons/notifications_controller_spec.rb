require 'rails_helper'

RSpec.describe ResponsiblePersons::NotificationsController, type: :controller do
  let(:user) { build(:user) }
  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user: user)
  end

  after do
    sign_out
  end

  describe "GET #index" do
    it "assigns @responsible_person" do
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "renders the index template" do
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(response).to render_template('responsible_persons/notifications/index')
    end

    it "counts pending notification files" do
      create(:notification_file, responsible_person: responsible_person, user: user)
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:pending_notification_files_count)).to eq(1)
    end

    it "gets the correct number of unfinished notifications from manual journey" do
      create(:draft_notification, responsible_person: responsible_person)
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:unfinished_notifications).count).to eq(1)
    end

    it "gets the correct number of unfinished notifications from upload journey" do
      create(:imported_notification, responsible_person: responsible_person)
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:unfinished_notifications).count).to eq(1)
    end

    it "gets the correct number of all unfinished notifications" do
      create(:draft_notification, responsible_person: responsible_person)
      create(:imported_notification, responsible_person: responsible_person)
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:unfinished_notifications).count).to eq(2)
    end

    it "gets the correct number of registered notifications" do
      create(:registered_notification, responsible_person: responsible_person)
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:registered_notifications).count).to eq(1)
    end

    it "does not allow user to access another Responsible Person's dashboard" do
      other_responsible_person = create(:responsible_person, email_address: "another.person@example.com")
      expect { get :index, params: { responsible_person_id: other_responsible_person.id } }
          .to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "GET /new" do
    it "creates new notification" do
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:notification)).to be_kind_of(Notification)
    end

    it "associates new notification with Responsible Person" do
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:notification).responsible_person).to eq(responsible_person)
    end

    it "redirects to the notification build controller" do
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(response).to redirect_to(new_notification_build_path(assigns(:notification).reference_number))
    end
  end

  describe "GET /edit" do
    let(:notification) { create(:notification, responsible_person: responsible_person) }
    let(:draft_notification) { create(:draft_notification, responsible_person: responsible_person) }

    it "assigns the correct notification" do
      get :edit, params: { responsible_person_id: responsible_person.id, reference_number: notification.reference_number }
      expect(assigns(:notification)).to eq(notification)
    end

    it "adds error if failed attempt to submit when images are pending anti virus check" do
      attach_image_to_draft_with_metadata({})
      get :edit, params: { responsible_person_id: responsible_person.id, reference_number: draft_notification.reference_number,
                           submit_failed: true }
      expect(assigns(:notification).errors[:image_uploads]).to include("waiting for files to pass anti virus check. Refresh to update")
    end

    it "adds error if failed attempt to submit when images have failed antivirus check" do
      draft_notification.image_uploads.build
      draft_notification.save
      get :edit, params: { responsible_person_id: responsible_person.id, reference_number: draft_notification.reference_number,
                           submit_failed: true }
      expect(assigns(:notification).errors[:image_uploads]).to include("failed anti virus check")
    end
  end

  describe "GET /confirmation" do
    let(:notification) { create(:notification, responsible_person: responsible_person) }
    let(:draft_notification) { create(:draft_notification, responsible_person: responsible_person) }

    it "assigns the correct notification" do
      get :confirmation, params: { responsible_person_id: responsible_person.id, reference_number: notification.reference_number }
      expect(assigns(:notification)).to eq(notification)
    end

    it "marks the notification as complete" do
      attach_image_to_draft_with_metadata(safe: true)
      get :confirmation, params: { responsible_person_id: responsible_person.id, reference_number: draft_notification.reference_number }
      expect(draft_notification.reload.state).to eq('notification_complete')
    end
  end

private

  def attach_image_to_draft_with_metadata(metadata)
    draft_notification.image_uploads.build

    image_upload = draft_notification.image_uploads.first
    image_upload.file.attach(fixture_file_upload("/testImage.png", "image/png"))
    image_upload.save

    blob = image_upload.file.blob
    blob.metadata = metadata
    blob.save
  end
end
