require "rails_helper"

RSpec.describe ResponsiblePersons::NotificationFilesController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }
  let(:valid_attributes) {
    [fixture_file_upload("testExportFile.zip")]
  }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { responsible_person_id: responsible_person.id }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "a new NotificationFile is created" do
        expect {
          post :create, params: { responsible_person_id: responsible_person.id, uploaded_files: valid_attributes }
        }.to change(NotificationFile, :count).by(1)
      end

      it "redirects to the notifications for the Responsible Person" do
        post :create, params: { responsible_person_id: responsible_person.id, uploaded_files: valid_attributes }
        expect(response).to redirect_to(responsible_person_notifications_path)
      end
    end
  end
end
