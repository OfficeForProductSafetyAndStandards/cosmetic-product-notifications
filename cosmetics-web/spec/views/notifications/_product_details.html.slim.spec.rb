require "rails_helper"

describe "notifications/_product_details.html.slim" do
  let(:responsible_person) { create(:responsible_person) }
  let(:current_user) { create(:user) }
  let(:notification) { create(:registered_notification, responsible_person: responsible_person) }

  context "when the user is a MSA" do
    before do
      allow(current_user).to receive(:can_view_product_ingredients?).and_return(false)

      render :partial => "notifications/product_details.html.slim", locals: { notification: notification, allow_edits: false, current_user: current_user }
    end

    it "does not render product imported status" do
      expect(response.body).not_to match(/Imported/)
    end

    it "does not render component formulations" do
      expect(response.body).not_to match(/Formulation given as/)
      expect(response.body).not_to match(/Frame formulation/)
    end

    it "does not render acute poisoning info" do
      expect(response.body).not_to match(/Acute poisoning information/)
    end

    it "does not render poisonous ingredients" do
      expect(response.body).not_to match(/Contains poisonous ingredients/)
    end

    it "does not render trigger questions" do
      expect(response.body).not_to match(/<tr class="govuk-table__row trigger-question">/)
    end

    it "does not render minimum pH" do
      expect(response.body).not_to match(/Minimum pH value/)
    end

    it "does not render Maximum pH" do
      expect(response.body).not_to match(/Maximum pH value/)
    end

    it "does not render still on the market" do
      expect(response.body).not_to match(/Still on the market/)
    end
  end
end
