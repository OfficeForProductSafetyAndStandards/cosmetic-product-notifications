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

  describe "#images_required?" do
    let(:notification) { build(:notification) }

    context "when the notification has no images uploaded" do
      context "when notifiying pre EU exit" do
        before do
          notification.was_notified_before_eu_exit = true
        end

        it "requires an image upload" do
          expect(notification).to be_images_required
        end
      end

      context "when notifiying post EU exit" do
        before do
          notification.was_notified_before_eu_exit = false
        end

        it "does not require an image upload" do
          expect(notification).to be_images_required
        end
      end
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
    let(:nano_element) { create(:nano_element, confirm_toxicology_notified: "yes", purposes: %w(other)) }
    let(:nano_material) { create(:nano_material, nano_elements: [nano_element]) }
    let(:component) { create(:component, nano_material: nano_material) }

    context "when no missing information" do
      context "when notified pre EU exit" do
        let(:notification) { create(:draft_notification, :pre_brexit, components: [component]) }

        it "can submit a notification" do
          expect(notification).to be_may_submit_notification
        end
      end

      context "when images are present and safe" do
        let(:notification) { create(:draft_notification, image_uploads: [image_upload], components: [component]) }
        let(:image_upload) { create(:image_upload, :uploaded_and_virus_scanned) }

        it "can submit a notification" do
          expect(notification).to be_may_submit_notification
        end
      end
    end

    context "when information is missing" do
      let(:nano_element) { create(:nano_element, confirm_toxicology_notified: "no", purposes: %w(other)) }
      let(:nano_material) { create(:nano_material, nano_elements: [nano_element]) }
      let(:component) { create(:component, nano_material: nano_material) }

      context "when notified pre EU exit" do
        let(:notification) { create(:draft_notification, :pre_brexit, components: [component]) }

        it "can not submit a notification" do
          expect(notification).not_to be_may_submit_notification
        end
      end

      context "when images is present and safe" do
        let(:notification) { create(:draft_notification, image_uploads: [image_upload], components: [component]) }
        let(:image_upload) { create(:image_upload, :uploaded_and_virus_scanned) }

        it "can not submit a notification" do
          expect(notification).not_to be_may_submit_notification
        end
      end
    end
  end
end
