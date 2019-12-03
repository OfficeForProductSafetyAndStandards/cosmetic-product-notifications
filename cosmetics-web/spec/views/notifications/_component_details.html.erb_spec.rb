require "rails_helper"

describe "notifications/_component_details.html.erb", type: :view do
  let(:responsible_person) { create(:responsible_person) }
  let(:user) { create(:user) }
  let(:notification) { create(:registered_notification, responsible_person: responsible_person) }
  let(:component) { create(:component, :with_poisonous_ingredients, :with_trigger_questions, notification: notification) }

  context "when the user is a MSA" do
    before do
      allow(user).to receive(:can_view_product_ingredients?).and_return(true)
      render partial: "notifications/component_details.html.erb", locals: { component: component, current_user: user }
    end

    it "renders CMR substances" do
      expect(response.body).to match(/Contains CMR substances/)
    end

    it "renders nanomaterials" do
      expect(response.body).to match(/Nanomaterials/)
    end

    it "renders physical form" do
      expect(response.body).to match(/Physical form/)
    end
  end
end
