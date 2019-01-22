require 'rails_helper'

RSpec.describe NotificationFilesController, type: :controller do
  before do
    allow(Keycloak::Client).to receive(:user_signed_in?).and_return(true)
  end

  after do
    allow(Keycloak::Client).to receive(:user_signed_in?).and_call_original
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
      get :new, params: {}
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new NotificationFile" do
        expect {
          post :create, params: { notification_file: valid_attributes }
        }.to change(NotificationFile, :count).by(1)
      end

      it "redirects to the created notification_file" do
        post :create, params: { notification_file: valid_attributes }
        expect(response).to redirect_to(NotificationFile.last)
      end
    end
  end
end
