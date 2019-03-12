require 'rails_helper'

RSpec.describe LandingPageController, type: :controller do
  describe "When not signed in" do
    describe "GET #index" do
      it "returns success status" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "does not assign a Responsible Person" do
        get :index
        expect(assigns(:responsible_person)).to eq(nil)
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template("landing_page/index")
      end
    end
  end

  describe "When signed in as a Responsible Person user" do
    let(:user) { build(:user) }
    let(:responsible_person_1) { create(:responsible_person, email_address: "one@example.com") }
    let(:responsible_person_2) { create(:responsible_person, email_address: "two@example.com") }

    before do
      responsible_person_1.add_user(user)
      responsible_person_2.add_user(user)

      sign_in_as_member_of_responsible_person(create(:responsible_person), user)
    end

    after do
      sign_out
    end

    describe "GET #index" do
      it "returns success status" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "assigns the first Responsible Person for the user" do
        get :index
        expect(assigns(:responsible_person)).to eq(responsible_person_1)
      end
    end
  end

  describe "When signed in as a Poison Centre user" do
    before do
      sign_in_as_poison_centre_user
    end

    after do
      sign_out
    end

    describe "GET #index" do
      it "redirects to the Poison Centre notifications index page" do
        get :index
        expect(response).to redirect_to(poison_centre_notifications_path)
      end
    end
  end
end
