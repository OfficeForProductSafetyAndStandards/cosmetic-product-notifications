require "rails_helper"

RSpec.describe Notification, type: :model do
  before do
    notification = described_class.create
    allow(notification)
      .to receive(:country_from_code)
      .with("country:NZ").and_return("New Zealand")
  end

  describe "updating product_name" do
    it "transitions state from empty to product_name_added" do
      notification = create(:notification)

      notification.product_name = "Super Shampoo"
      notification.save

      expect(notification.state).to eq("product_name_added")
    end

    it "adds errors if product_name updated to be blank" do
      notification = create(:notification)

      notification.product_name = ""
      notification.save

      expect(notification.errors[:product_name]).to eql(['Enter the product name'])
    end
  end

  describe "updating under three years" do
    it "adds errors if under_three_years updated to be blank" do
      notification = create(:notification)

      notification.under_three_years = nil
      notification.save(context: :for_children_under_three)

      expect(notification.errors[:under_three_years]).to eql(['Select yes if the product is intended to be used on children under 3 years old'])
    end
  end
end
