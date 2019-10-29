require 'rails_helper'

RSpec.describe "Check your answers page", type: :request do
  include RSpecHtmlMatchers

  let(:user) { build(:user) }
  let!(:responsible_person) { create(:responsible_person) }
  let(:notification) { create(:draft_notification, responsible_person: responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  after do
    sign_out
  end

  describe "GET #edit" do
    context "when the component has CMRS" do
      let!(:component) { create(:component, :with_poisonous_ingredients, :with_trigger_questions, notification: notification, cmrs: [create(:cmr)]) }

      before do
        get "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit"
      end

      it "should have a UK cosmetics product number " do
        expect(response.body).to include("UK cosmetic product number:")
      end

      it "displays that the product contains CMRs" do
        expect(response.body).to include("Contains CMR substances")
      end

      it "displays whether CMRs are present" do
        expect(response.body).to include("Yes")
      end

      it "displays a list of CMRs" do
        expect(response.body).to include(component.cmrs.first.display_name)
      end
    end

    context "when the component has no CMRs" do
      let(:component) { create(:component, :with_poisonous_ingredients, :with_trigger_questions, notification: notification) }

      before do
        get "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit"
      end

      it "displays whether CMRs are present" do
        expect(response.body).to include("No")
      end

      it "displays a list of CMRs" do
        expect(response.body).not_to include('td#cmr-list')
      end
    end
  end
end
