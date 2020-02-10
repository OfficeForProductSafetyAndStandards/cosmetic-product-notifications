require "rails_helper"

RSpec.describe "Notifications page", :with_stubbed_antivirus, type: :request do
  after do
    sign_out
  end

  context "when signed in as a poison centre user but accesing from submit domain", with_errors_rendered: true do
    let(:user) { create(:user) }
    let(:responsible_person) { create(:responsible_person) }

    before do
      sign_in_as_poison_centre_user(user: user)
      configure_requests_for_submit_domain
      get "/responsible_persons/#{responsible_person.id}/notifications"
    end

    it "redirects to invalid account page" do
      expect(response).to redirect_to("/invalid-account")
    end
  end

  context "when signed in as a user of a responsible_person" do
    let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
    let(:user) { build(:user) }

    let(:other_responsible_person) { create(:responsible_person, :with_a_contact_person) }
    let(:other_user) { build(:user) }

    before do
      sign_in_as_member_of_responsible_person(responsible_person, user)
    end

    context "when requesting notifications for the company associated with the user" do
      before do
        # Setup notifications belonging to the company
        create(:draft_notification, responsible_person: responsible_person)
        create(:registered_notification, responsible_person: responsible_person)
        create(:notification_file, responsible_person: responsible_person, user: user,
           upload_error: "uploaded_file_not_a_zip")
        create(:notification_file, responsible_person: responsible_person, user: user)

        # Setup notifications belonging to other companies or users
        create(:draft_notification, responsible_person: other_responsible_person)
        create(:registered_notification, responsible_person: other_responsible_person)
        create(:notification_file, responsible_person: other_responsible_person, user: user,
           upload_error: "uploaded_file_not_a_zip")
        create(:notification_file, responsible_person: responsible_person, user: other_user)
        create(:notification_file, responsible_person: other_responsible_person, user: other_user)


        get "/responsible_persons/#{responsible_person.id}/notifications"
      end

      it "renders the page successfully" do
        expect(response.status).to be(200)
      end

      it "displays the number of draft notifications" do
        expect(response.body).to include("Incomplete (1)")
      end

      it "displays the number of completed notifications" do
        expect(response.body).to include("Notified (1)")
      end

      it "displays the number of notification files containing errors" do
        expect(response.body).to include("Errors (1)")
      end

      it "displays the number of notification files being checked" do
        expect(response.body).to include("Checking 1 notification file")
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
