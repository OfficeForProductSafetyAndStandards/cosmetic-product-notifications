require "rails_helper"

RSpec.describe "Notifications page", :with_stubbed_antivirus, :with_stubbed_notify, type: :request do
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

    context "when requesting notifications for the company associated with the user" do
      before do
        travel_to(Time.zone.local(2021, 2, 20, 13))

        # Setup notifications belonging to the company
        create(:draft_notification, responsible_person: responsible_person)
        create(:registered_notification, product_name: "Product 1", reference_number: 1, responsible_person: responsible_person)
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
      end

      context "when visiting notification page" do
        before do
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
      end

      context "when downloading notifications as a file" do
        before do
          travel_to(Time.zone.local(2021, 2, 20, 13, 1))
          create(:registered_notification, product_name: "Product 2", reference_number: 2, responsible_person: responsible_person)

          Notification.all.each(&:cache_notification_for_csv!)

          get "/responsible_persons/#{responsible_person.id}/notifications.csv"
        end

        let(:expected_csv) do
          <<~CSV
            Product name,UK cosmetic product number,Notification date,EU Reference number,EU Notification date,Internal reference,Number of items,Item 1 Level 1 category,Item 1 Level 2 category,Item 1 Level 3 category
            Product 1,UKCP-00000001,2021-02-20 13:00:00 +0000,,,,0
            Product 2,UKCP-00000002,2021-02-20 13:01:00 +0000,,,,0
          CSV
        end

        it "returns file with proper notifications" do
          expect(response.body).to eq expected_csv
        end
      end
    end

    context "when requesting notifications for non-existant company ID" do
      before do
        get "/responsible_persons/99999999/notifications"
      end

      it "responds with a 404 Page not found error" do
        expect(response).to redirect_to("/404")
      end
    end
  end
end
