require "rails_helper"

# rubocop:disable RSpec/DescribeClass
describe "notifications/_component_details.html.slim" do
# rubocop:enable RSpec/DescribeClass
  let(:responsible_person) { create(:responsible_person) }
  let(:user) { create(:user) }
  let(:notification) { create(:registered_notification, responsible_person: responsible_person) }

  context "when the component has CMRS" do
    let(:component) { create(:component, :with_poisonous_ingredients, :with_trigger_questions, notification: notification, cmrs: [create(:cmr)]) }

    before do
      allow(user).to receive(:can_view_product_ingredients?).and_return(false)
      render partial: "notifications/component_details.html.slim", locals: { component: component, current_user: user }
    end

    it "displays that the product contains CMRs" do
      expect(response.body).to have_css('th#contains-cmrs', text: "Contains CMR substances")
    end

    it "displays whether CMRs are present" do
      expect(response.body).to have_css('td#has-cmrs', text: "Yes")
    end

    it "displays a list of CMRs" do
      expect(response.body).to have_css('td#cmr-names', text: component.cmrs.first.display_name)
    end
  end

  context "when the component has no CMRs" do
    let(:component) { create(:component, :with_poisonous_ingredients, :with_trigger_questions, notification: notification) }

    before do
      allow(user).to receive(:can_view_product_ingredients?).and_return(false)
      render partial: "notifications/component_details.html.slim", locals: { component: component, current_user: user }
    end

    it "displays whether CMRs are present" do
      expect(response.body).to have_css('td#has-cmrs', text: "No")
    end

    it "displays a list of CMRs" do
      expect(response.body).not_to have_css('td#cmr-list')
    end
  end
end
