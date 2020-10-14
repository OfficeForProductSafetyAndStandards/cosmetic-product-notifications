require "rails_helper"

RSpec.describe DeclarationController, type: :controller do
  describe "When signed in as a business user" do
    let(:first_time_user) { create(:submit_user, has_accepted_declaration: false) }

    before do
      configure_requests_for_submit_domain
      sign_in(first_time_user)
    end

    after do
      sign_out(:submit_user)
    end

    describe "GET #show" do
      it "renders the business declaration template" do
        get :show
        expect(response).to render_template("declaration/business_declaration")
      end
    end

    describe "POST #accept" do
      it "records the declaration as accepted" do
        post :accept
        expect(first_time_user.reload.has_accepted_declaration?).to be true
      end

      it "redirects to the root path" do
        post :accept
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "When signed in as a Poison Centre user" do
    let(:first_time_user) { create(:poison_centre_user, first_login: true) }

    before do
      sign_in_as_poison_centre_user(user: first_time_user)
    end

    after do
      sign_out(:search_user)
    end

    describe "GET #show" do
      it "renders the Poison Centre declaration template" do
        get :show
        expect(response).to render_template("declaration/poison_centre_declaration")
      end
    end
  end
end
