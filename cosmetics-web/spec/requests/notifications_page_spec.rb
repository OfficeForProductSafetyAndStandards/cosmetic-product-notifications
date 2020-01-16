require "rails_helper"

RSpec.describe "Notifications page", :with_stubbed_antivirus, type: :request do
  after do
    sign_out
  end

  context "when signed in as a poison centre user", with_errors_rendered: true do
    let(:user) { create(:user) }
    let(:responsible_person) { create(:responsible_person) }

    before do
      sign_in_as_poison_centre_user(user: user)
      get "/responsible_persons/#{responsible_person.id}/notifications"
    end

    it "responds with a 403 Forbidden status code" do
      expect(response.status).to be(403)
    end
  end

  context "when signed in as a user of a responsible_person" do
    let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }

    before do
      sign_in_as_member_of_responsible_person(responsible_person)
    end

    context "when requesting notifications for the company associated with the user" do
      before do
        get "/responsible_persons/#{responsible_person.id}/notifications"
      end

      it "renders the page successfully" do
        expect(response.status).to be(200)
      end
    end

    context "when requesting notifications for non-existant company ID" do
      before do
        get "/responsible_persons/99999999/notifications"
      end

      it "responds with a 404 Page not found error" do
        expect(response.status).to be(404)
      end
    end
  end
end
