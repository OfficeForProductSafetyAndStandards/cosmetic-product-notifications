require 'rails_helper'

RSpec.describe NotificationFilesController, type: :controller do
  before do
    sign_in_as_member_of_responsible_person(create(:responsible_person))
  end

  after do
    sign_out
  end

  let(:valid_attributes) {
    { uploaded_file: fixture_file_upload("testImage.png", "image/png") }
  }

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
