require 'rails_helper'

RSpec.describe "Check your answers page", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person) }
  let(:notification) { create(:draft_notification, responsible_person: responsible_person) }
  let(:params) do
    {
      responsible_person_id: responsible_person.id,
      reference_number: notification.reference_number
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
      let!(:component) { create(:component, notification: notification, cmrs: [create(:cmr)]) }

      before do
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
  end
end
