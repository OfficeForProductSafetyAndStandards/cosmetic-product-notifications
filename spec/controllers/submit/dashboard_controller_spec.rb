require "rails_helper"

RSpec.describe Submit::DashboardController, type: :controller do
  before do
    configure_requests_for_submit_domain
  end

  let(:responsible_person_with_no_contact_person) { create(:responsible_person) }
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:user) { create(:submit_user) }

  describe "When signed in as a Responsible Person user" do
    before do
      sign_in_as_member_of_responsible_person(responsible_person)
    end

    after do
      sign_out(:submit_user)
    end

    describe "GET #show" do
      it "redirects to cosmetic products page" do
        get :show
        expect(response).to redirect_to(responsible_person_notifications_path(responsible_person))
      end
    end
  end
end
