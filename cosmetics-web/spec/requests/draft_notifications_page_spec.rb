require "rails_helper"

RSpec.describe "Draft Notifications page", :with_stubbed_antivirus, :with_stubbed_notify, type: :request do
  context "when signed in as a poison centre user but accessing from submit domain", with_errors_rendered: true do
    let(:responsible_person) { create(:responsible_person) }

    before do
      sign_in_as_poison_centre_user
      configure_requests_for_submit_domain
      get "/responsible_persons/#{responsible_person.id}/notifications"
    end

    after do
      sign_out(:search_user)
    end

    it "redirects to invalid account page" do
      expect(response).to redirect_to("/invalid-account")
    end
  end

  context "when signed in as a user of a responsible_person" do
    let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
    let(:user) { build(:submit_user) }

    let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }
    let(:other_user) { build(:submit_user) }

    before do
      sign_in_as_member_of_responsible_person(responsible_person, user)
    end

    after do
      sign_out(:submit_user)
    end

    context "when visiting notification page with no draft notifications" do
      before do
        get "/responsible_persons/#{responsible_person.id}/draft-notifications"
      end

      it "renders the page successfully" do
        expect(response.status).to be(200)
      end

      it "displays the number of draft notifications" do
        expect(response.body).to include("There are currently no draft notifications")
      end

      context "when the user has an incomplete notification" do
        before do
          create(:draft_notification, responsible_person:)
          get "/responsible_persons/#{responsible_person.id}/draft-notifications"
        end

        it "displays the draft notification" do
          expect(response.body).to include("There are currently 1 draft notifications")
        end
      end
    end
  end
end
