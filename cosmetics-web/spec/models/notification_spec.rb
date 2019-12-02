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

      expect(notification.errors[:product_name]).to eql(["Enter the product name"])
    end
  end

  describe "updating under three years" do
    it "adds errors if under_three_years updated to be blank" do
      notification = create(:notification)

      notification.under_three_years = nil
      notification.save(context: :for_children_under_three)

      expect(notification.errors[:under_three_years]).to eql(["Select yes if the product is intended to be used on children under 3 years old"])
    end
  end

  describe "#missing_information?" do
    let(:notification) { build(:notification) }

    before do
      allow(notification).to receive(:nano_material_required?).and_return(true)
      allow(notification).to receive(:formulation_required?).and_return(true)
      allow(notification).to receive(:images_required?).and_return(true)
    end

    it "has no missing information" do
      expect(notification).to be_missing_information
    end

    it "nano material is complete" do
      allow(notification).to receive(:nano_material_required?).and_return(false)

      expect(notification).to be_missing_information
    end

    it "frame formation is not required" do
      allow(notification).to receive(:formulation_required?).and_return(false)

      expect(notification).to be_missing_information
    end

    it "does not need a product image" do
      allow(notification).to receive(:images_required?).and_return(false)

      expect(notification).to be_missing_information
    end

    context "when there is no more information required" do
      it "has no missing information" do
        allow(notification).to receive(:nano_material_required?).and_return(false)
        allow(notification).to receive(:formulation_required?).and_return(false)
        allow(notification).to receive(:images_required?).and_return(false)

        expect(notification).not_to be_missing_information
      end
    end
  end

  describe "#may_submit_notification?" do
    let(:notification) { create(:draft_notification) }

    context "when no missing information" do
      before do
        allow(notification).to receive(:missing_information?).and_return(false)
      end

      context "when notified pre EU exit" do
        before do
          allow(notification).to receive(:notified_pre_eu_exit?).and_return(true)
        end

        it "can submit a notification" do
          expect(notification).to be_may_submit_notification
        end
      end

      context "when images are present and safe" do
        before do
          allow(notification).to receive(:images_are_present_and_safe?).and_return(true)
        end

        it "can submit a notification" do
          expect(notification).to be_may_submit_notification
        end
      end
    end

    context "when information is missing" do
      before do
        allow(notification).to receive(:missing_information?).and_return(true)
      end

      context "when notified pre EU exit" do
        before do
          allow(notification).to receive(:notified_pre_eu_exit?).and_return(true)
        end

        it "can not submit a notification" do
          expect(notification).not_to be_may_submit_notification
        end
      end

      context "when images are present and safe" do
        before do
          allow(notification).to receive(:images_are_present_and_safe?).and_return(true)
        end

        it "can not submit a notification" do
          expect(notification).not_to be_may_submit_notification
        end
      end
    end
  end
end
