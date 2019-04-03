require 'rails_helper'

RSpec.describe DeclarationController, type: :controller do
  let(:first_time_user) { build(:user, first_login: true) }

  describe "When signed in as a business user" do
    before do
      sign_in(as_user: first_time_user)
    end

    after do
      sign_out
    end

    describe "GET #show" do
      it "renders the business declaration template" do
        get :show
        expect(response).to render_template("declaration/business_declaration")
      end
    end

    describe "POST #accept" do
      it "records the declaration as accepted" do
        post :accept, params: { accept_declaration: "checked" }
        expect(first_time_user.has_accepted_declaration?).to be true
      end

      it "redirects to the root path" do
        post :accept, params: { accept_declaration: "checked" }
        expect(response).to redirect_to(root_path)
      end

      it "returns an error if the declaration is not accepted" do
        post :accept, params: { accept_declaration: "unchecked" }
        expect(assigns(:errors).first[:text]).to include("You must confirm the declaration")
      end
    end
  end

  describe "When signed in as a Poison Centre user" do
    before do
      sign_in_as_poison_centre_user(user: first_time_user)
    end

    after do
      sign_out
    end

    describe "GET #show" do
      it "renders the Poison Centre declaration template" do
        get :show
        expect(response).to render_template("declaration/poison_centre_declaration")
      end
    end
  end
end
