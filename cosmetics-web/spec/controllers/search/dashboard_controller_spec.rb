require "rails_helper"

RSpec.describe Search::DashboardController, type: :controller do
  describe "When signed in as a Poison Centre user" do
    before do
      sign_in_as_poison_centre_user
    end

    after do
      sign_out(:search_user)
    end

    describe "GET #show" do
      it "redirects to the Poison Centre/MSA notifications index page" do
        get :show
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

    describe "GET #show" do
      it "redirects to the Poison Centre/MSA notifications index page" do
        get :show
        expect(response).to redirect_to(poison_centre_notifications_path)
      end
    end
  end
end
