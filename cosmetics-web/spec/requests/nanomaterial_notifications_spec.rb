require "rails_helper"

RSpec.describe "Nanomaterial notifications", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person) }
  let(:other_company) { create(:responsible_person) }

  let(:submitted_nanomaterial_notification) { create(:nanomaterial_notification, :submitted, responsible_person: responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET /responsible_persons/ID/nanomaterials" do
    context "when user is associated with the responsible person" do
      before do
        get "/responsible_persons/#{responsible_person.id}/nanomaterials"
      end

      it "is successful" do
        expect(response.code).to eql("200")
      end

      it "has a page heading" do
        expect(response.body).to have_h1_with_text("Nanomaterials")
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
  end

  describe "POST /responsible_persons/ID/nanomaterials" do
    before do
      post "/responsible_persons/#{responsible_person.id}/nanomaterials", params: {
        nanomaterial_notification: {
          iupac_name: iupac_name,
        },
      }
    end

    context "with a valid name" do
      let(:iupac_name) { "Test nanomaterial" }

      it "redirects to the EU notification page" do
        expect(response).to redirect_to(/\/nanomaterials\/\d+\/notified_to_eu/)
      end

      it "creates a nanomaterial notification with that name" do
        nanomaterial_notification = responsible_person.nanomaterial_notifications
          .find_by(iupac_name: "Test nanomaterial")

        expect(nanomaterial_notification).not_to be_nil
      end

      it "associates the nanomaterial notification with the current user" do
        nanomaterial_notification = responsible_person.nanomaterial_notifications
          .find_by(iupac_name: "Test nanomaterial")

        # TODO: specify this using mocked user_id
        expect(nanomaterial_notification.user_id).not_to be_nil
      end
    end

    context "with no name given" do
      let(:iupac_name) { "" }

      it "renders the page" do
        expect(response.code).to eql("200")
      end

      it "displays an error message" do
        expect(response.body).to include("There is a problem")
      end
    end
  end

  describe "GET /nanomaterials/ID/notified_to_eu" do
    context "when the user has access" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: responsible_person, iupac_name: "Zinc oxide") }

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}/notified_to_eu"
      end

      it "is successful" do
        expect(response.code).to eql("200")
      end

      it "has a page heading" do
        expect(response.body).to have_h1_with_text("Was the EU notified about Zinc oxide on CPNP before 1 February 2020?")
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
    context "when the user has access" do
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: responsible_person) }

      before do
        patch "/nanomaterials/#{nanomaterial_notification.id}/notified_to_eu", params: nanomaterial_params
      end

      context "when a valid pre-Brexit date is entered" do
        let(:nanomaterial_params) {
          {
          eu_notified: "true",
          "notified_to_eu_on(3i)" => "01",  # day
          "notified_to_eu_on(2i)" => "01",  # month
          "notified_to_eu_on(1i)" => "2020", # year
        }
        }

        it "redirects to the upload PDF page" do
          expect(response).to redirect_to("/nanomaterials/#{nanomaterial_notification.id}/upload_file")
        end
      end

      context "when the EU wasn’t notified" do
        let(:nanomaterial_params) {
          {
          eu_notified: "false",
        }
        }

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
        let(:file) { Rack::Test::UploadedFile.new("spec/fixtures/testPdf.pdf", "application/pdf", true) }
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
      let(:nanomaterial_notification) { create(:nanomaterial_notification, responsible_person: responsible_person) }

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
      let(:nanomaterial_notification) { create(:nanomaterial_notification, :submitted, responsible_person: responsible_person, iupac_name: "Zinc oxide") }

      before do
        get "/nanomaterials/#{nanomaterial_notification.id}/confirmation"
      end

      it "is successful" do
        expect(response.code).to eql("200")
      end

      it "has a page heading" do
        expect(response.body).to have_h1_with_text("You’ve told us about Zinc oxide")
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
