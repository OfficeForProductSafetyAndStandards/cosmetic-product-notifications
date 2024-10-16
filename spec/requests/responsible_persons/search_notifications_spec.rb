require "rails_helper"

RSpec.describe "Search notifications page", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:submit_user) { responsible_person.responsible_person_users.first.user }

  let(:cream) { create(:notification, :registered, :with_component, notification_complete_at: 1.day.ago, product_name: "Cream", responsible_person:) }

  before do
    configure_requests_for_submit_domain
    cream
    Notification.import_to_opensearch(force: true)
    sign_in_as_member_of_responsible_person(responsible_person, submit_user)
  end

  describe "GET #show" do
    context "when visiting search notifications page" do
      before do
        get responsible_person_search_notifications_path(responsible_person.id)
      end

      it "renders the page successfully" do
        expect(response.status).to be(200)
      end

      it "renders the search header" do
        expect(response).to render_template("responsible_persons/search_notifications/_search_header")
      end

      it "renders the search form" do
        expect(response).to render_template("responsible_persons/search_notifications/_search_form")
      end
    end

    context "when searching for a notification" do
      let(:search_params) do
        {
          notification_search_form: {
            q: "Cream",
          },
        }
      end

      before do
        get responsible_person_search_notifications_path(responsible_person.id, search_params)
      end

      it "displays the results header" do
        expect(response).to render_template("responsible_persons/search_notifications/_results_header")
      end

      it "displays the results body" do
        expect(response).to render_template("responsible_persons/search_notifications/_results")
      end

      it "displays the result" do
        expect(response.body).to have_tag("span", text: "Cream")
      end
    end
  end
end
