require 'rails_helper'

RSpec.describe ResponsiblePersons::NotificationFilesController, type: :controller do
  before do
    sign_in_test_user
  end

  after do
    sign_out_user
  end

  # This should return the minimal set of attributes required to create a valid
  # NotificationFile. As you add validations to NotificationFile, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        uploaded_file: fixture_file_upload("testImage.png", "image/png")
    }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # NotificationFilesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #new" do
    it "returns a success response" do
      responsible_person = ResponsiblePerson.create
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new NotificationFile" do
        responsible_person = ResponsiblePerson.create
        expect {
          post :create, params: { responsible_person_id: responsible_person.id, notification_file: valid_attributes }
        }.to change(NotificationFile, :count).by(1)
      end

      it "redirects to the notifications for the Responsible Person" do
        responsible_person = ResponsiblePerson.create
        post :create, params: { responsible_person_id: responsible_person.id, notification_file: valid_attributes }
        expect(response).to redirect_to(responsible_person_notifications_path)
      end
    end
  end
end
