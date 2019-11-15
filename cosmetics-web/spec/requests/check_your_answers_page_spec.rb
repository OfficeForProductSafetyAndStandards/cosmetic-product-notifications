require "rails_helper"

RSpec.describe "Check your answers page", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person) }
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
    sign_out
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

      it "displays whether CMRs are present" do
        expect(response.body).to have_tag("td#has-cmrs")
      end

      it "displays a list of CMRs" do
        expect(response.body).not_to have_tag("td#cmr-names")
      end
    end

    context "when the notification was post-Brexit" do
      let(:notification) { create(:notification, :post_brexit, responsible_person: responsible_person) }

      before do
        get edit_responsible_person_notification_path(params)
      end

      it "includes a back link to the image upload page" do
        expect(response.body).to have_back_link_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/build/add_product_image")
      end
    end

    context "when the notification was pre-Brexit and there was a single component with the no pH range needed" do
      let(:notification) { create(:notification, :pre_brexit, responsible_person: responsible_person) }
      let!(:component) { create(:component, notification: notification) }

      before do
        get edit_responsible_person_notification_path(params)
      end

      it "includes a back link to the pH question" do
        expect(response.body).to have_back_link_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/trigger_question/select_ph_range")
      end
    end

    context "when the notification was pre-Brexit and there was a single component with a specific pH range entered" do
      let(:notification) { create(:notification, :pre_brexit, responsible_person: responsible_person) }
      let!(:component) { create(:component, notification: notification, minimum_ph: 2.5, maximum_ph: 2.9) }

      before do
        get edit_responsible_person_notification_path(params)
      end

      it "includes a back link to the pH range" do
        expect(response.body).to have_back_link_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/trigger_question/ph")
      end
    end

    context "when the notification was pre-Brexit and there were multiple components" do
      let(:notification) { create(:notification, :pre_brexit, responsible_person: responsible_person, components: [create(:component), create(:component)]) }

      before do
        get edit_responsible_person_notification_path(params)
      end

      it "includes a back link to list of components page" do
        expect(response.body).to have_back_link_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/build/add_new_component")
      end
    end
  end
end
