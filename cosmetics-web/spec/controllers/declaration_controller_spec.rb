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
