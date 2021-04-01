require "rails_helper"

RSpec.describe "Check your answers page", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:notification) { create(:draft_notification, responsible_person: responsible_person) }
  let(:params) do
    {
      responsible_person_id: responsible_person.id,
      reference_number: notification.reference_number,
    }
  end

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET #edit" do
    it "displays the UK cosmetics product number " do
      get edit_responsible_person_notification_path(params)

      expect(response.body).to include("UK cosmetic product number:")
    end

    context "when the component has CMRS" do
      before do
        create(:component, notification: notification, cmrs: [create(:cmr)])

        get edit_responsible_person_notification_path(params)
      end

      it "displays that the product contains CMRs" do
        expect(response.body).to have_tag("th#contains-cmrs")
      end

      it "displays whether CMRs are present" do
        expect(response.body).to have_tag("td#has-cmrs")
      end

      it "displays a list of CMRs" do
        expect(response.body).to have_tag("td#cmr-names")
      end
    end

    context "when the component has no CMRs" do
      before do
        create(:component, notification: notification)

        get edit_responsible_person_notification_path(params)
      end

      it "displays a list of CMRs" do
        expect(response.body).not_to have_tag("td#cmr-names")
      end
    end

    context "when the notification there is a single component with no pH range needed" do
      let(:notification) { create(:notification, responsible_person: responsible_person) }
      let!(:component) { create(:component, notification: notification) }

      it "includes a back link to the pH question" do
        get edit_responsible_person_notification_path(params)
        expect(response.body).to have_back_link_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/trigger_question/select_ph_range")
      end
    end

    context "when there is a single component with a specific pH range entered" do
      let(:notification) { create(:notification, responsible_person: responsible_person) }
      let!(:component) { create(:component, notification: notification, minimum_ph: 2.5, maximum_ph: 2.9) }

      it "includes a back link to the pH range" do
        get edit_responsible_person_notification_path(params)
        expect(response.body).to have_back_link_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/trigger_question/ph")
      end
    end

    context "when there were multiple components" do
      let(:notification) { create(:notification, responsible_person: responsible_person, components: [create(:component), create(:component)]) }

      it "includes a back link to list of components page" do
        get edit_responsible_person_notification_path(params)
        expect(response.body).to have_back_link_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/build/add_new_component")
      end
    end

    context "when the notification used a ZIP file from CPNP" do
      let(:notification) { create(:notification, :via_zip_file, responsible_person: responsible_person) }

      it "includes a back link to incomplete notifications page" do
        get edit_responsible_person_notification_path(params)
        expect(response.body).to have_back_link_to("/responsible_persons/#{responsible_person.id}/notifications\#incomplete")
      end
    end
  end
end
