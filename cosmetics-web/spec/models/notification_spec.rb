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

  describe "#images_missing_or_with_virus?" do
    context "when notifiying pre EU exit with no images uploaded yet" do
      let(:notification) { build_stubbed(:draft_notification, :pre_brexit) }

      it "requires images" do
        expect(notification.images_missing_or_with_virus?).to be true
      end
    end

    context "when notifiying post EU exit with no images uploaded yet" do
      let(:notification) { build_stubbed(:draft_notification, :post_brexit) }

      it "requires images" do
        expect(notification.images_missing_or_with_virus?).to be true
      end
    end

    context "when notifiying post EU exit with 1 image uploaded but not virus-scanned" do
      let(:image_upload) { build_stubbed(:image_upload) }
      let(:notification) { build_stubbed(:draft_notification, :post_brexit, image_uploads: [image_upload]) }

      it "does not require images" do
        expect(notification.images_missing_or_with_virus?).to be false
      end
    end

    context "when notifiying post EU exit with 1 image uploaded and flagged by the antivirus" do
      let(:image_upload) { build_stubbed(:image_upload, :uploaded_and_virus_identified) }
      let(:notification) { build_stubbed(:draft_notification, :post_brexit, image_uploads: [image_upload]) }

      it "requires images" do
        expect(notification.images_missing_or_with_virus?).to be true
      end
    end

    context "when notifiying post EU exit with 1 image uploaded and virus-scanned" do
      let(:image_upload) { build_stubbed(:image_upload, :uploaded_and_virus_scanned) }
      let(:notification) { build_stubbed(:draft_notification, :post_brexit, image_uploads: [image_upload]) }

      it "does not require images" do
        expect(notification.images_missing_or_with_virus?).to be false
      end
    end
  end

  describe "#images_missing_or_not_passed_antivirus_check?" do
    context "when notifiying pre EU exit with no images uploaded yet" do
      let(:notification) { build_stubbed(:draft_notification, :pre_brexit) }

      it "requires images" do
        expect(notification.images_missing_or_not_passed_antivirus_check?).to be true
      end
    end

    context "when notifiying post EU exit with no images uploaded yet" do
      let(:notification) { build_stubbed(:draft_notification, :post_brexit) }

      it "requires images" do
        expect(notification.images_missing_or_not_passed_antivirus_check?).to be true
      end
    end

    context "when notifiying post EU exit with 1 image uploaded but not virus-scanned" do
      let(:image_upload) { build_stubbed(:image_upload) }
      let(:notification) { build_stubbed(:draft_notification, :post_brexit, image_uploads: [image_upload]) }

      it "does not require images" do
        expect(notification.images_missing_or_not_passed_antivirus_check?).to be true
      end
    end

    context "when notifiying post EU exit with 1 image uploaded and flagged by the antivirus" do
      let(:image_upload) { build_stubbed(:image_upload, :uploaded_and_virus_identified) }
      let(:notification) { build_stubbed(:draft_notification, :post_brexit, image_uploads: [image_upload]) }

      it "requires images" do
        expect(notification.images_missing_or_not_passed_antivirus_check?).to be true
      end
    end

    context "when notifiying post EU exit with 1 image uploaded and virus-scanned" do
      let(:image_upload) { build_stubbed(:image_upload, :uploaded_and_virus_scanned) }
      let(:notification) { build_stubbed(:draft_notification, :post_brexit, image_uploads: [image_upload]) }

      it "does not require images" do
        expect(notification.images_missing_or_not_passed_antivirus_check?).to be false
      end
    end
  end

  describe "#missing_information?" do
    let(:notification) { build(:notification) }

    before do
      allow(notification).to receive(:nano_material_required?).and_return(true)
      allow(notification).to receive(:formulation_required?).and_return(true)
      allow(notification).to receive(:images_missing_or_not_passed_antivirus_check?).and_return(true)
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
      allow(notification).to receive(:images_missing_or_not_passed_antivirus_check?).and_return(false)

      expect(notification).to be_missing_information
    end

    context "when there is no more information required" do
      it "has no missing information" do
        allow(notification).to receive(:nano_material_required?).and_return(false)
        allow(notification).to receive(:formulation_required?).and_return(false)
        allow(notification).to receive(:images_missing_or_not_passed_antivirus_check?).and_return(false)

        expect(notification).not_to be_missing_information
      end
    end
  end

  describe "#may_submit_notification?", :with_stubbed_antivirus do
    let(:nano_element) { build(:nano_element, confirm_toxicology_notified: "yes", purposes: %w[other]) }
    let(:nano_material) { build(:nano_material, nano_elements: [nano_element]) }
    let(:component) { build(:component, nano_material: nano_material) }

    context "when no information is missing" do
      let(:image_upload) { create(:image_upload, :uploaded_and_virus_scanned) }
      let(:notification) { build(:draft_notification, :pre_brexit, image_uploads: [image_upload], components: [component]) }

      it "can submit a notification" do
        expect(notification).to be_may_submit_notification
      end
    end

    context "when information is missing" do
      let(:notification) { build(:draft_notification, :post_brexit, components: [component]) }

      it "can not submit a notification" do
        expect(notification).not_to be_may_submit_notification
      end
    end
  end

  describe "#destroy_notification!" do
    before { notification }

    let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
    let(:submit_user) { responsible_person.responsible_person_users.first.user }

    context "when is draft" do
      let(:notification) { create(:draft_notification, responsible_person: responsible_person) }

      it "uses #destroy!" do
        expect {
          notification.destroy_notification!(submit_user)
        }.to change(described_class, :count).by(-1)
      end
    end

    context "when is completed" do
      let(:notification) { create(:registered_notification, responsible_person: responsible_person) }
      let(:service) { instance_double(NotificationDeleteService, call: nil) }

      it "uses NotificationDeleteService" do
        allow(NotificationDeleteService).to receive(:new).with(notification, submit_user) { service }

        notification.destroy_notification!(submit_user)

        expect(service).to have_received(:call)
      end
    end
  end
end
