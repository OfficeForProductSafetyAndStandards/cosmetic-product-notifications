require "rails_helper"

RSpec.describe "application/_unfinished_product.html.erb", type: :view do
  let(:responsible_person) { create(:responsible_person) }
  let(:notification) { create(:registered_notification, responsible_person: responsible_person) }

  context "when a notification is missing information" do
    before do
      allow(notification).to receive(:missing_information?).and_return(true)

      render partial: "application/unfinished_product.html.erb", locals: { notification: notification }
    end

    it "allows the user to add information" do
      expect(response.body).to match(/Add missing information/)
    end
  end

  context "when a notification is not missing information" do
    before do
      allow(notification).to receive(:missing_information?).and_return(false)

      render partial: "application/unfinished_product.html.erb", locals: { notification: notification }
    end

    it "allows the user to confirm and notify notification" do
      expect(response.body).to match(/Confirm and notify/)
    end
  end
end
