require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe "When signed in as a Responsible Person user" do
    let(:user) { build(:user) }
    let(:responsible_person_1) { create(:responsible_person, email_address: "one@example.com") }

    before do
      responsible_person_1.add_user(user)
      sign_in_as_member_of_responsible_person(create(:responsible_person), user)
    end

    after do
      sign_out
    end

    describe "GET #show" do
      it "redirects to cosmetic products page" do
        get :show
        expect(response).to redirect_to(responsible_person_notifications_path(responsible_person_1))
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
      sign_out
    end

    describe "GET #show" do
      it "redirects to the Poison Centre/MSA notifications index page" do
        get :show
        expect(response).to redirect_to(poison_centre_notifications_path)
      end
    end
  end
end
