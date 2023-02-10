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
      it "redirects to the correct notifications index page" do
        get :show
        expect(response).to redirect_to(poison_centre_notifications_search_path)
      end
    end
  end

  describe "When signed in as an OPSS General user" do
    before do
      sign_in_as_opss_general_user
    end

    after do
      sign_out(:search_user)
    end

    describe "GET #show" do
      it "redirects to the correct notifications index page" do
        get :show
        expect(response).to redirect_to(poison_centre_notifications_search_path)
      end
    end
  end

  describe "When signed in as an OPSS Enforcement user" do
    before do
      sign_in_as_opss_enforcement_user
    end

    after do
      sign_out(:search_user)
    end

    describe "GET #show" do
      it "redirects to the correct notifications index page" do
        get :show
        expect(response).to redirect_to(poison_centre_notifications_search_path)
      end
    end
  end

  describe "When signed in as a Trading Standards user" do
    before do
      sign_in_as_trading_standards_user
    end

    after do
      sign_out(:search_user)
    end

    describe "GET #show" do
      it "redirects to the correct notifications index page" do
        get :show
        expect(response).to redirect_to(poison_centre_notifications_search_path)
      end
    end
  end
end
