require 'rails_helper'

RSpec.describe ResponsiblePersons::NotificationsController, type: :controller do
  let(:user) { build(:user) }
  let(:responsible_person) { create(:responsible_person) }
  let(:predefined_component) { create(:component) }
  let(:ranges_component) { create(:ranges_component) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  after do
    sign_out
  end

  describe "GET #index" do
    it "assigns the correct Responsible Person" do
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

    it "excludes pending notification files for other users" do
      other_user = build(:user, email: "other.user@example.com")
      responsible_person.add_user(other_user)

      create(:notification_file, responsible_person: responsible_person, user: other_user)
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:pending_notification_files_count)).to eq(0)
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

    it "gets the correct number of submitted notifications" do
      create(:registered_notification, responsible_person: responsible_person)
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:registered_notifications).count).to eq(1)
    end

    it "does not allow the user to access another Responsible Person's dashboard" do
      other_responsible_person = create(:responsible_person)
      expect { get :index, params: { responsible_person_id: other_responsible_person.id } }
          .to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "GET /show" do
    let(:notification) { create(:registered_notification, responsible_person: responsible_person) }

    it "assigns the correct notification" do
      get :show, params: { responsible_person_id: responsible_person.id, reference_number: notification.reference_number }
      expect(assigns(:notification)).to eq(notification)
    end

    it "renders the index template" do
      get :show, params: { responsible_person_id: responsible_person.id, reference_number: notification.reference_number }
      expect(response).to render_template('responsible_persons/notifications/show')
    end

    it "does not allow the user to show a notification for a Responsible Person they not belong to" do
      other_responsible_person = create(:responsible_person)
      other_notification = create(:registered_notification, responsible_person: other_responsible_person)
      expect {
        get :show, params: { responsible_person_id: other_responsible_person.id, reference_number: other_notification.reference_number }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "GET /new" do
    it "creates a new notification" do
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:notification)).to be_kind_of(Notification)
    end

    it "associates the new notification with current Responsible Person" do
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:notification).responsible_person).to eq(responsible_person)
    end

    it "redirects to the notification build controller" do
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(response).to redirect_to(new_responsible_person_notification_build_path(assigns(:responsible_person), assigns(:notification).reference_number))
    end

    it "does not allow the user to create a new notification for a Responsible Person they not belong to" do
      other_responsible_person = create(:responsible_person)
      expect {
        get :new, params: { responsible_person_id: other_responsible_person.id }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "GET /edit" do
    let(:draft_notification) { create(:draft_notification, responsible_person: responsible_person) }

    it "assigns the correct notification" do
      get :edit, params: { responsible_person_id: responsible_person.id, reference_number: draft_notification.reference_number }
      expect(assigns(:notification)).to eq(draft_notification)
    end

    it "adds error if failed attempt to submit when images are pending antivirus check" do
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

    it "does not allow the user to edit notification for a Responsible Person they not belong to" do
      other_responsible_person = create(:responsible_person)
      other_notification = create(:draft_notification, responsible_person: other_responsible_person)
      expect {
        get :edit, params: { responsible_person_id: other_responsible_person.id, reference_number: other_notification.reference_number }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "POST /confirm" do
    let(:draft_notification) { create(:draft_notification, responsible_person: responsible_person) }

    it "assigns the correct notification" do
      post :confirm, params: { responsible_person_id: responsible_person.id, reference_number: draft_notification.reference_number }
      expect(assigns(:notification)).to eq(draft_notification)
    end

    it "marks the notification as complete" do
      attach_image_to_draft_with_metadata(safe: true)
      post :confirm, params: { responsible_person_id: responsible_person.id, reference_number: draft_notification.reference_number }
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
