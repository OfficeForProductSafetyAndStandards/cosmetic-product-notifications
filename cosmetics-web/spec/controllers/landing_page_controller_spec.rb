require "rails_helper"

RSpec.describe LandingPageController, type: :controller do
  describe "When not signed in" do
    after do
      reset_domain_request_mocking
    end

    describe "GET #index" do
      it "returns success status" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "does not assign a Responsible Person" do
        get :index
        expect(assigns(:responsible_person)).to eq(nil)
      end

      it "renders the submit landing page template for submit domain requests" do
        configure_requests_for_submit_domain
        get :index
        expect(response).to render_template("landing_page/submit_landing_page")
      end

      it "renders the search landing page template for search domain requests" do
        configure_requests_for_search_domain
        get :index
        expect(response).to render_template("landing_page/search_landing_page")
      end
    end
  end

  describe "When signed in as a Responsible Person user" do
    let(:user) { build(:submit_user) }
    let(:responsible_person_1) { create(:responsible_person, :with_a_contact_person) }
    let(:responsible_person_2) { create(:responsible_person, :with_a_contact_person) }

    before do
      responsible_person_1.add_user(user)
      responsible_person_2.add_user(user)

      sign_in_as_member_of_responsible_person(create(:responsible_person, :with_a_contact_person), user)
    end

    after do
      sign_out(:submit_user)
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
      sign_out(:search_user)
    end

    describe "GET #index" do
      it "redirects to the Poison Centre/MSA notifications index page" do
        get :index
        expect(response).to redirect_to(poison_centre_notifications_path)
      end
    end
  end

  describe "When signed in as a MSA user" do
    before do
      sign_in_as_msa_user
    end

    after do
      sign_out(:search_user)
    end

    describe "GET #index" do
      it "redirects to the Poison Centre/MSA notifications index page" do
        get :index
        expect(response).to redirect_to(poison_centre_notifications_path)
      end
    end
  end
end
