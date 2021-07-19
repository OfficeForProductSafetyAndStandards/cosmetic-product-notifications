require "rails_helper"

RSpec.describe "Nanomaterial notifications", :with_stubbed_antivirus, type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
  let(:submit_user) { responsible_person.responsible_person_users.first.user }
  let(:other_company) { create(:responsible_person, :with_a_contact_person) }

  let(:submitted_nanomaterial_notification) { create(:nanomaterial_notification, :submitted, responsible_person: responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, submit_user)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET /responsible_persons/ID/nanomaterials" do
    context "when user is associated with the responsible person" do
      it "is successful" do
        get "/responsible_persons/#{responsible_person.id}/nanomaterials"
        expect(response.code).to eql("200")
      end

      it "has a page heading" do
        get "/responsible_persons/#{responsible_person.id}/nanomaterials"
        expect(response.body).to have_tag("h1", text: /Nanomaterials/)
      end

      it "has a page title" do
        get "/responsible_persons/#{responsible_person.id}/nanomaterials"
        expect(response.body).to have_title("Nanomaterials")
      end

      it "lists the submitted nanomaterial notification" do
        submitted_nanomaterial_notification
        get "/responsible_persons/#{responsible_person.id}/nanomaterials"
        expect(response.body).to have_tag("li h2", text: /#{submitted_nanomaterial_notification.name}/)
      end

      it "does not list a non submitted nanomaterial notification" do
        create(:nanomaterial_notification, :not_submitted, name: "Not submitted nano", responsible_person: responsible_person)
        get "/responsible_persons/#{responsible_person.id}/nanomaterials"
        expect(response.body).not_to have_tag("li h2", text: /"Not submitted nano"/)
      end
    end

    context "when user attempts to look at a another company’s nanomaterials" do
      it "raises an a 'Not authorized' error" do
        expect {
          get "/responsible_persons/#{other_company.id}/nanomaterials"
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "GET /responsible_persons/:id/nanomaterials.csv" do
    let(:rp) { responsible_person }
    let(:expected_csv) do
      <<~CSV
        Nanomaterial name,UK Nanomaterial number ,EU Notification date,UK Notification date
        Zinc oxide,UKN-#{nanomaterial_notification1.id},,2021-07-20 12:00:00 +0100
        Zinc oxide,UKN-#{nanomaterial_notification2.id},2021-07-17,2021-07-20 12:00:00 +0100
      CSV
    end
    let(:user_id)                    { submit_user.id }
    let(:nanomaterial_notification1) { create(:nanomaterial_notification, :submittable, :submitted, user_id: user_id, responsible_person: rp) }
    let(:nanomaterial_notification2) { create(:nanomaterial_notification, :submittable, :submitted, user_id: user_id, responsible_person: rp, notified_to_eu_on: 3.days.ago.to_date) }
    let(:nanomaterial_notification3) { create(:nanomaterial_notification, user_id: user_id, responsible_person: rp) }

    before do
      travel_to(Time.zone.local(2021, 7, 20, 13))

      nanomaterial_notification1
      nanomaterial_notification2
      nanomaterial_notification3

      get "/responsible_persons/#{responsible_person.id}/nanomaterials.csv"
    end

    it "is successful" do
      expect(response.code).to eql("200")
    end

    it "returns file with proper notifications" do
      expect(response.body).to eq expected_csv
    end
  end

  describe "GET /nanomaterials/ID" do
    context "when user is associated with the responsible person" do
      let(:nanomaterial_notification) do
        create(:nanomaterial_notification, :submitted, responsible_person: responsible_person)
      end

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}"
      end

      it "is successful" do
        expect(response.code).to eql("200")
      end

      it "has the nanomaterial page heading" do
        expect(response.body).to have_tag("h1", text: /#{nanomaterial_notification.name}/)
      end

      it "has the nanomaterial page title" do
        expect(response.body).to have_title(nanomaterial_notification.name)
      end
    end

    context "when user attempts to look at a another company’s nanomaterials" do
      let(:nanomaterial_notification) do
        create(:nanomaterial_notification, :submitted, responsible_person: other_company)
      end

      it "raises an a 'Not authorized' error" do
        expect {
          get "/nanomaterials/#{nanomaterial_notification.id}"
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "GET /responsible_persons/ID/nanomaterials/new" do
    before do
      get "/responsible_persons/#{responsible_person.id}/nanomaterials/new"
    end

    it "is successful" do
      expect(response.code).to eql("200")
    end

    it "has a page heading" do
      expect(response.body).to have_h1_with_text("What is the name of the nanomaterial?")
    end

    it "has a page title" do
      expect(response.body).to have_title("What is the name of the nanomaterial?")
    end

    it "includes a back link to the Nanomaterials tab page" do
      expect(response.body).to have_back_link_to("/responsible_persons/#{responsible_person.id}/nanomaterials")
    end
  end

  describe "POST /responsible_persons/ID/nanomaterials" do
    before do
      post "/responsible_persons/#{responsible_person.id}/nanomaterials", params: {
        nanomaterial_notification: {
          name: name,
        },
      }
    end

    context "with a valid name" do
      let(:name) { "Test nanomaterial" }

      it "redirects to the EU notification page" do
        expect(response).to redirect_to(/\/nanomaterials\/\d+\/notified_to_eu/)
      end

      it "creates a nanomaterial notification with that name" do
        nanomaterial_notification = responsible_person.nanomaterial_notifications
          .find_by(name: "Test nanomaterial")

        expect(nanomaterial_notification).not_to be_nil
      end

      it "associates the nanomaterial notification with the current user" do
        nanomaterial_notification = responsible_person.nanomaterial_notifications
          .find_by(name: "Test nanomaterial")

        # TODO: specify this using mocked user_id
        expect(nanomaterial_notification.user_id).not_to be_nil
      end
    end

    context "with no name given" do
      let(:name) { "" }

      it "renders the page" do
        expect(response.code).to eql("200")
      end

      it "displays an error message" do
        expect(response.body).to include("There is a problem")
      end
    end
  end

  describe "GET /nanomaterials/ID/name" do
    context "when the user has access" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: responsible_person, name: "Zinc oxide") }

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}/name"
      end

      it "is successful" do
        expect(response.code).to eql("200")
      end

      it "has a page heading" do
        expect(response.body).to have_h1_with_text("What is the name of the nanomaterial?")
      end

      it "has a page title" do
        expect(response.body).to have_title("What is the name of the nanomaterial?")
      end
    end

    context "when all the other questions have been answered" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, :submittable, responsible_person: responsible_person) }

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}/name"
      end

      it "includes a back link to the Check your answers page" do
        expect(response.body).to have_back_link_to("/nanomaterials/#{nanomaterial_notification.id}/review")
      end
    end

    context "when the notification has already been submitted" do
      before do
        get "/nanomaterials/#{submitted_nanomaterial_notification.id}/name"
      end

      it "redirects to the confirmation page" do
        expect(response).to redirect_to("/nanomaterials/#{submitted_nanomaterial_notification.id}/confirmation")
      end
    end

    context "when the nanomaterial notification belongs to a different company" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: other_company) }

      it "displays an error" do
        expect {
          get "/nanomaterials/#{nanomaterial_notification.id}/notified_to_eu"
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "PATCH /nanomaterials/ID/name" do
    before do
      patch "/nanomaterials/#{nanomaterial_notification.id}/name", params: {
        nanomaterial_notification: {
          name: name,
        },
      }
    end

    context "when the user has access and notification is submittable" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, :submittable, responsible_person: responsible_person, name: "Previous name") }

      context "with a valid new name" do
        let(:name) { "Updated name" }

        it "redirects to the Check your answers page" do
          expect(response).to redirect_to("/nanomaterials/#{nanomaterial_notification.id}/review")
        end

        it "updates the name of the nanomaterial" do
          expect(nanomaterial_notification.reload.name).to eql("Updated name")
        end
      end

      context "with no new name given" do
        let(:name) { "" }

        it "renders the page" do
          expect(response.code).to eql("200")
        end

        it "displays an error message" do
          expect(response.body).to include("There is a problem")
        end
      end
    end

    context "when the user has access but EU question not yet answered" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: responsible_person, name: "Previous name", eu_notified: nil) }

      context "with a valid new name" do
        let(:name) { "Updated name" }

        it "redirects to the EU notification question page" do
          expect(response).to redirect_to("/nanomaterials/#{nanomaterial_notification.id}/notified_to_eu")
        end
      end
    end
  end

  describe "GET /nanomaterials/ID/notified_to_eu" do
    context "when the user has access" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: responsible_person, name: "Zinc oxide") }

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}/notified_to_eu"
      end

      it "is successful" do
        expect(response.code).to eql("200")
      end

      it "has a page heading" do
        expect(response.body).to have_h1_with_text("Was the EU notified about Zinc oxide on CPNP before 1 January 2021?")
      end

      it "has a page title" do
        expect(response.body).to have_title("Was the EU notified about Zinc oxide on CPNP before 1 January 2021?")
      end

      it "includes a back link to the name page" do
        expect(response.body).to have_back_link_to("/nanomaterials/#{nanomaterial_notification.id}/name")
      end
    end

    context "when all the other questions have been answered" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, :submittable, responsible_person: responsible_person) }

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}/notified_to_eu"
      end

      it "includes a back link to Check your answers page" do
        expect(response.body).to have_back_link_to("/nanomaterials/#{nanomaterial_notification.id}/review")
      end
    end

    context "when the notification has already been submitted" do
      before do
        get "/nanomaterials/#{submitted_nanomaterial_notification.id}/notified_to_eu"
      end

      it "redirects to the confirmation page" do
        expect(response).to redirect_to("/nanomaterials/#{submitted_nanomaterial_notification.id}/confirmation")
      end
    end

    context "when the nanomaterial notification belongs to a different company" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: other_company) }

      it "displays an error" do
        expect {
          get "/nanomaterials/#{nanomaterial_notification.id}/notified_to_eu"
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "PATCH /nanomaterials/ID/notified_to_eu" do
    context "when the user has access but the file hasn’t been uploaded yet" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: responsible_person) }

      before do
        patch "/nanomaterials/#{nanomaterial_notification.id}/notified_to_eu", params: nanomaterial_params
      end

      context "when a valid pre-Brexit date is entered" do
        let(:nanomaterial_params) do
          {
            eu_notified: "true",
            notified_to_eu_on: {
              day: "01",
              month: "01",
              year: "2020",
            },
          }
        end

        it "redirects to the upload PDF page" do
          expect(response).to redirect_to("/nanomaterials/#{nanomaterial_notification.id}/upload_file")
        end
      end

      context "when the EU wasn’t notified" do
        let(:nanomaterial_params) do
          {
            eu_notified: "false",
          }
        end

        it "redirects to the upload PDF page" do
          expect(response).to redirect_to("/nanomaterials/#{nanomaterial_notification.id}/upload_file")
        end
      end

      context "when no answer was selected" do
        let(:nanomaterial_params) { {} }

        it "renders an error page" do
          expect(response.code).to eql("200")
        end
      end

      context "when a an invalid date is entered" do
        let(:nanomaterial_params) do
          {
            eu_notified: "true",
            notified_to_eu_on: {
              day: "12",
              month: "30",
              year: "2020",
            },
          }
        end

        it "renders an error page" do
          expect(response.code).to eql("200")
        end

        it "displays an error message" do
          expect(response.body).to include("There is a problem")
        end
      end
    end

    context "when the user has access and the file has been uploaded" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, :submittable, responsible_person: responsible_person) }

      before do
        patch "/nanomaterials/#{nanomaterial_notification.id}/notified_to_eu", params: nanomaterial_params
      end

      context "when a valid answer is given" do
        let(:nanomaterial_params) { { eu_notified: "false" } }

        it "redirects to the Check your answers page" do
          expect(response).to redirect_to("/nanomaterials/#{nanomaterial_notification.id}/review")
        end
      end
    end

    context "when the nanomaterial notification belongs to a different company" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: other_company) }

      it "raises an a 'Not authorized' error" do
        expect {
          patch "/nanomaterials/#{nanomaterial_notification.id}/notified_to_eu"
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "GET /nanomaterials/ID/upload_file" do
    context "when the user has access" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: responsible_person) }

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}/upload_file"
      end

      it "is successful" do
        expect(response.code).to eql("200")
      end

      it "has a page heading" do
        expect(response.body).to have_h1_with_text("Upload details about the nanomaterial")
      end

      it "has a page title" do
        expect(response.body).to have_title("Upload details about the nanomaterial")
      end

      it "includes a back link to EU notification question page" do
        expect(response.body).to have_back_link_to("/nanomaterials/#{nanomaterial_notification.id}/notified_to_eu")
      end
    end

    context "when all questions have been answered" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, :submittable, responsible_person: responsible_person) }

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}/upload_file"
      end

      it "includes a back link to Check your answers page" do
        expect(response.body).to have_back_link_to("/nanomaterials/#{nanomaterial_notification.id}/review")
      end
    end

    context "when the notification has already been submitted" do
      before do
        get "/nanomaterials/#{submitted_nanomaterial_notification.id}/upload_file"
      end

      it "redirects to the confirmation page" do
        expect(response).to redirect_to("/nanomaterials/#{submitted_nanomaterial_notification.id}/confirmation")
      end
    end

    context "when the nanomaterial notification belongs to a different company" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: other_company) }

      it "displays an error" do
        expect {
          get "/nanomaterials/#{nanomaterial_notification.id}/upload_file"
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "PATCH /nanomaterials/ID/file" do
    context "when the user has access" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: responsible_person) }

      before do
        patch "/nanomaterials/#{nanomaterial_notification.id}/file", params: params
      end

      context "when a file is selected" do
        let(:file) { Rack::Test::UploadedFile.new("spec/fixtures/files/testPdf.pdf", "application/pdf", true) }
        let(:params) { { nanomaterial_notification: { file: file } } }

        it "redirects to the Check your answers page" do
          expect(response).to redirect_to("/nanomaterials/#{nanomaterial_notification.id}/review")
        end
      end

      context "when no file is selected" do
        let(:params) { {} }

        it "is renders a page" do
          expect(response.code).to eql("200")
        end

        it "displays an error message" do
          expect(response.body).to include("There is a problem")
        end
      end
    end

    context "when the nanomaterial notification belongs to a different company" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: other_company) }

      it "displays an error" do
        expect {
          patch "/nanomaterials/#{nanomaterial_notification.id}/file"
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "GET /nanomaterials/ID/review" do
    context "when the user has access" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: responsible_person) }

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}/review"
      end

      it "is successful" do
        expect(response.code).to eql("200")
      end

      it "has a page heading" do
        expect(response.body).to have_h1_with_text("Check your answers")
      end

      it "has a page title" do
        expect(response.body).to have_title("Check your answers")
      end
    end

    context "when the notification has already been submitted" do
      before do
        get "/nanomaterials/#{submitted_nanomaterial_notification.id}/review"
      end

      it "redirects to the confirmation page" do
        expect(response).to redirect_to("/nanomaterials/#{submitted_nanomaterial_notification.id}/confirmation")
      end
    end

    context "when the nanomaterial notification belongs to a different company" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: other_company) }

      it "displays an error" do
        expect {
          get "/nanomaterials/#{nanomaterial_notification.id}/review"
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "PATCH /nanomaterials/ID/submission" do
    context "when the user has access" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, :submittable, responsible_person: responsible_person) }

      before do
        patch "/nanomaterials/#{nanomaterial_notification.id}/submission"
      end

      it "sets a submission date" do
        expect(nanomaterial_notification.reload.submitted_at).to be_within(1.second).of(Time.zone.now)
      end

      it "redirects to the confirmation page" do
        expect(response).to redirect_to("/nanomaterials/#{nanomaterial_notification.id}/confirmation")
      end
    end

    context "when there is no file attached" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: responsible_person, name: "Test", eu_notified: false) }

      before do
        patch "/nanomaterials/#{nanomaterial_notification.id}/submission"
      end

      it "renders the page" do
        expect(response.code).to eql("200")
      end

      it "displays an error message" do
        expect(response.body).to include("There is a problem")
      end
    end

    context "when the nanomaterial notification belongs to a different company" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: other_company) }

      it "displays an error" do
        expect {
          patch "/nanomaterials/#{nanomaterial_notification.id}/submission"
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "GET /nanomaterials/ID/confirmation" do
    context "when the user has access" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, :submitted, responsible_person: responsible_person, name: "Zinc oxide") }

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}/confirmation"
      end

      it "is successful" do
        expect(response.code).to eql("200")
      end

      it "has a page heading" do
        expect(response.body).to have_h1_with_text("You’ve told us about Zinc oxide")
      end

      it "has a page title" do
        expect(response.body).to have_title("You’ve told us about Zinc oxide")
      end
    end

    context "when the nanomaterial notification belongs to a different company" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, :submitted, responsible_person: other_company) }

      it "displays an error" do
        expect {
          get "/nanomaterials/#{nanomaterial_notification.id}/confirmation"
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when the nanomaterial notification has not yet been submitted" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, :not_submitted, responsible_person: responsible_person) }

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}/confirmation"
      end

      it "redirects to the check your answers page" do
        expect(response).to redirect_to("/nanomaterials/#{nanomaterial_notification.id}/review")
      end
    end
  end
end
