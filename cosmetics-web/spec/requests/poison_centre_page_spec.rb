require "rails_helper"

RSpec.describe "Poison centre page", type: :request do
  include RSpecHtmlMatchers

  let(:user) { create(:user) }
  let(:responsible_person) { create(:responsible_person) }
  let(:notification) { create(:draft_notification, responsible_person: responsible_person) }
  let(:params) do
    {
      reference_number: notification.reference_number,
    }
  end

  before do
    sign_in_as_poison_centre_user(user: user)
  end

  after do
    sign_out
  end

  describe "GET #show" do
    it "displays the cosmetics product name " do
      get poison_centre_notification_path(params)

      expect(response.body).to include(notification.product_name)
    end

    context "when the component does not have CMRS" do
      before do
        create(:component, notification: notification)

        get poison_centre_notification_path(params)
      end

      it "displays a list of CMRs" do
        expect(response.body).to have_tag("td#cmr-names")
      end
    end
  end

  context "when the component has CMRS" do
    before do
      create(:component, notification: notification, cmrs: [create(:cmr)])

      get poison_centre_notification_path(params)
    end

    it "displays a list of CMRs" do
      expect(response.body).to have_tag("td#cmr-names")
    end
  end
end
