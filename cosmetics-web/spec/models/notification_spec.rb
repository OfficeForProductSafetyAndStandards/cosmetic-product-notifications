require "rails_helper"

RSpec.describe Notification, :with_stubbed_antivirus, type: :model do
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
    context "when notifiying with no images uploaded yet" do
      let(:notification) { build_stubbed(:draft_notification) }

      it "requires images" do
        expect(notification.images_missing_or_with_virus?).to be true
      end
    end

    context "when notifiying with 1 image uploaded but not virus-scanned" do
      let(:image_upload) { build_stubbed(:image_upload) }
      let(:notification) { build_stubbed(:draft_notification, image_uploads: [image_upload]) }

      it "does not require images" do
        expect(notification.images_missing_or_with_virus?).to be false
      end
    end

    context "when notifiying with 1 image uploaded and flagged by the antivirus" do
      let(:image_upload) { build_stubbed(:image_upload, :uploaded_and_virus_identified) }
      let(:notification) { build_stubbed(:draft_notification, image_uploads: [image_upload]) }

      it "requires images" do
        expect(notification.images_missing_or_with_virus?).to be true
      end
    end

    context "when notifiying with 1 image uploaded and virus-scanned" do
      let(:image_upload) { build_stubbed(:image_upload, :uploaded_and_virus_scanned) }
      let(:notification) { build_stubbed(:draft_notification, image_uploads: [image_upload]) }

      it "does not require images" do
        expect(notification.images_missing_or_with_virus?).to be false
      end
    end
  end

  describe "#images_missing_or_not_passed_antivirus_check?" do
    context "when notifiying with no images uploaded yet" do
      let(:notification) { build_stubbed(:draft_notification) }

      it "requires images" do
        expect(notification.images_missing_or_not_passed_antivirus_check?).to be true
      end
    end

    context "when notifiying with 1 image uploaded but not virus-scanned" do
      let(:image_upload) { build_stubbed(:image_upload) }
      let(:notification) { build_stubbed(:draft_notification, image_uploads: [image_upload]) }

      it "does not require images" do
        expect(notification.images_missing_or_not_passed_antivirus_check?).to be true
      end
    end

    context "when notifiying with 1 image uploaded and flagged by the antivirus" do
      let(:image_upload) { build_stubbed(:image_upload, :uploaded_and_virus_identified) }
      let(:notification) { build_stubbed(:draft_notification, image_uploads: [image_upload]) }

      it "requires images" do
        expect(notification.images_missing_or_not_passed_antivirus_check?).to be true
      end
    end

    context "when notifiying with 1 image uploaded and virus-scanned" do
      let(:image_upload) { build_stubbed(:image_upload, :uploaded_and_virus_scanned) }
      let(:notification) { build_stubbed(:draft_notification, image_uploads: [image_upload]) }

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

  describe "#nano_material_required?" do
    let(:nano_element) { create(:nano_element, nano_material: nano_material) }

    before do
      component
    end

    context "when notification does not have nano materials" do
      let(:notification) { create(:notification) }
      let(:component) { create(:component, notification: notification) }

      it "returns false" do
        expect(notification).not_to be_nano_material_required
      end
    end

    context "when notification does have nano material but component doesn't" do
      let(:notification) { create(:notification) }
      let(:nano_material) { create(:nano_material, notification: notification) }
      let(:component) { create(:component, notification: notification) }

      before { nano_material }

      it "returns true" do
        expect(notification).to be_nano_material_required
      end
    end

    context "when notification and component does have nano material" do
      let(:notification) { create(:notification) }
      let(:nano_material) { create(:nano_material, notification: notification) }
      let(:component) { create(:component, notification: notification, with_nano_materials: [nano_material]) }

      before { nano_material }

      it "returns false" do
        expect(notification).not_to be_nano_material_required
      end
    end
  end

  describe "#may_submit_notification?", :with_stubbed_antivirus do
    let(:nano_element) { build(:nano_element, confirm_toxicology_notified: "yes", purposes: %w[other]) }
    let(:nano_material) { build(:nano_material, nano_elements: [nano_element]) }
    let(:component) { build(:component, nano_material: nano_material) }

    context "when no information is missing" do
      let(:image_upload) { create(:image_upload, :uploaded_and_virus_scanned) }
      let(:notification) { build(:draft_notification, image_uploads: [image_upload], components: [component]) }

      it "can submit a notification" do
        expect(notification).to be_may_submit_notification
      end
    end

    context "when information is missing" do
      let(:notification) { build(:draft_notification, components: [component]) }

      it "can not submit a notification" do
        expect(notification).not_to be_may_submit_notification
      end
    end
  end

  describe "#can_be_deleted?" do
    it "can be deleted if the notification is not complete" do
      notification = build_stubbed(:draft_notification)
      expect(notification.can_be_deleted?).to eq true
    end

    context "when the notification is complete" do
      let(:notification) { build_stubbed(:registered_notification) }

      it "can be deleted if the notification was completed within the allowed deletion window" do
        notification.notification_complete_at = Time.zone.now
        expect(notification.can_be_deleted?).to eq true
      end

      it "can't be deleted if the notification was completed outside the allowed deletion window" do
        notification.notification_complete_at = (described_class::DELETION_PERIOD_DAYS + 1).days.ago
        expect(notification.can_be_deleted?).to eq false
      end
    end
  end

  describe "#cache_notification_for_csv!" do
    let(:notification) { create(:notification, :with_components) }

    it "is saved properly" do
      notification.cache_notification_for_csv!
      expect(notification.reload.csv_cache).to eq "#{notification.product_name},#{notification.reference_number_for_display},#{notification.notification_complete_at},,,,2,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products\n"
    end
  end

  describe "notification submision" do
    let(:notification) { create(:notification, :draft_complete, :with_components) }
    let(:image_upload) { create(:image_upload, :uploaded_and_virus_scanned, notification: notification) }

    before do
      image_upload
      notification.submit_notification!
    end

    it "caches csv" do
      expect(notification.reload.csv_cache).to eq "#{notification.product_name},#{notification.reference_number_for_display},#{notification.notification_complete_at},,,,2,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products,Hair and scalp products,Hair colouring products,Nonoxidative hair colour products\n"
    end
  end

  describe "deletion" do
    let(:responsible_person) { create(:responsible_person_with_user, :with_a_contact_person) }
    let(:notification) { create(:notification, :registered, :with_components, responsible_person: responsible_person) }
    let(:image_upload) { create(:image_upload, :uploaded_and_virus_scanned, notification: notification) }
    let(:deleted_notification) { DeletedNotification.first }

    describe "#soft_delete!" do
      describe "deleted notification record" do
        let!(:notification_attributes) { notification.attributes }

        before { notification.soft_delete! }

        it "is created with proper attributes" do
          Notification::DELETABLE_ATTRIBUTES.each do |attribute|
            expect(deleted_notification[attribute]).to eq(notification_attributes[attribute]), "'#{attribute}' should be set"
          end
        end

        it "is linked to notification" do
          expect(deleted_notification.notification).to eq notification
        end

        it "has notification state" do
          expect(deleted_notification.state).to eq notification_attributes["state"]
        end
      end

      describe "#destroy" do
        it "works as #soft_delete!" do
          notification.destroy
          expect(notification.reload.state).to eq "deleted"
        end
      end

      describe "#destroy!" do
        it "works as #soft_delete!" do
          notification.destroy!
          expect(notification.reload.state).to eq "deleted"
        end
      end

      describe "notification that is soft deleted" do
        it "removes all attributes properly" do
          notification.soft_delete!
          notification.reload

          Notification::DELETABLE_ATTRIBUTES.each do |attribute|
            expect(notification[attribute]).to eq(nil), "'#{attribute}' attribute should be empty"
          end
        end

        it "can not be double deleted" do
          expect {
            notification.soft_delete!
            notification.soft_delete!
          }.to change(DeletedNotification, :count).by(1)
        end

        it "has deleted state" do
          notification.soft_delete!
          expect(notification.reload.state).to eq "deleted"
        end

        it "has components" do
          components = notification.components
          notification.soft_delete!
          expect(notification.reload.components).to eq components
        end

        it "has image upload" do
          notification.soft_delete!
          expect(notification.reload.image_uploads).to eq [image_upload]
        end

        it "has responsible_person" do
          notification.soft_delete!
          expect(notification.reload.responsible_person).to eq responsible_person
        end

        it "is linked to deleted_notification" do
          notification.soft_delete!
          expect(notification.deleted_notification).to eq deleted_notification
        end
      end
    end

    describe "#hard_delete!" do
      it "deletes notification from database" do
        notification
        expect {
          notification.hard_delete!
        }.to change(described_class, :count).by(-1)
        expect { notification.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "deletes the image upload associated to the notification from database" do
        image_upload
        expect {
          notification.hard_delete!
        }.to change(ImageUpload, :count).by(-1)
        expect { image_upload.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      context "when the notification was soft deleted" do
        let!(:notification) { create(:notification, :deleted) }
        let(:deleted_notification) { notification.deleted_notification }

        it "deletes the 'deleted notification' record from database" do
          expect {
            notification.hard_delete!
          }.to change(DeletedNotification, :count).by(-1)
          expect { deleted_notification.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end

  describe "confirm and accept validation" do
    context "when there is nano material not assigned to component" do
      let(:notification) { create(:notification) }

      let(:nano_material1) { create(:nano_material, notification: notification) }
      let(:nano_element1) { create(:nano_element, nano_material: nano_material1, inci_name: "Nano 1") }

      let(:nano_material2) { create(:nano_material, notification: notification) }
      let(:nano_element2) { create(:nano_element, nano_material: nano_material2, inci_name: "Nano 2") }

      let(:component) { create(:component, notification: notification) }

      before do
        nano_element1
        nano_element2
      end

      it "is not valid" do
        expect(notification.valid?(:accept_and_submit)).to eq false
      end

      it "is valid" do
        expect(notification.valid?).to eq true
      end


      it "has proper error messages" do
        notification.valid?(:accept_and_submit)

        expect(notification.errors.messages[:base]).to eq (["Nano 1 is not included in any items", "Nano 2 is not included in any items"])
      end
    end
  end
end
