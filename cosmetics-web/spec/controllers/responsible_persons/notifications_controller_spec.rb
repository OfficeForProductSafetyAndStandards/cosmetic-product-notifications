require "rails_helper"

RSpec.describe ResponsiblePersons::NotificationsController, :with_stubbed_antivirus, type: :controller do
  let(:user) { build(:submit_user) }
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:predefined_component) { create(:component) }
  let(:ranges_component) { create(:ranges_component) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET #index" do
    it "assigns the correct Responsible Person" do
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "renders the index template" do
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(response).to render_template("responsible_persons/notifications/index")
    end

    it "gets the correct number of unfinished notifications" do
      create(:draft_notification, responsible_person: responsible_person)
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:unfinished_notifications).count).to eq(1)
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
      expect(response).to render_template("responsible_persons/notifications/show")
    end

    it "does not allow the user to show a notification for a Responsible Person they not belong to" do
      other_responsible_person = create(:responsible_person)
      other_notification = create(:registered_notification, responsible_person: other_responsible_person)
      expect {
        get :show, params: { responsible_person_id: other_responsible_person.id, reference_number: other_notification.reference_number }
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "does not shows deleted notification" do
      reference_number = notification.reference_number
      notification.destroy!
      get :show, params: { responsible_person_id: responsible_person.id, reference_number: reference_number }
      expect(response).to redirect_to("/404")
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

    it "displays the new notification page" do
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(response).to render_template("responsible_persons/notifications/new")
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

    it "does not allow the user to edit notification for a Responsible Person they not belong to" do
      other_responsible_person = create(:responsible_person)
      other_notification = create(:draft_notification, responsible_person: other_responsible_person)
      expect {
        get :edit, params: { responsible_person_id: other_responsible_person.id, reference_number: other_notification.reference_number }
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "does not shows deleted notification" do
      reference_number = draft_notification.reference_number
      draft_notification.destroy!
      get :edit, params: { responsible_person_id: responsible_person.id, reference_number: reference_number }
      expect(response).to redirect_to("/404")
    end

    context "when the notification is already submitted" do
      subject(:request) { get(:edit, params: { responsible_person_id: responsible_person.id, reference_number: notification.reference_number }) }

      let(:notification) { create(:registered_notification, responsible_person: responsible_person) }

      it "redirects to the notifications page" do
        expect(request).to redirect_to(responsible_person_notification_path(responsible_person, notification))
      end
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
