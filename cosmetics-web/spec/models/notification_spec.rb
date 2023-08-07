require "rails_helper"

RSpec.describe Notification, :with_stubbed_antivirus, type: :model do
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

  describe "#may_submit_notification?", :with_stubbed_antivirus do
    let(:nano_material) { build(:nano_material, confirm_toxicology_notified: "yes", purposes: %w[other]) }
    let(:component) { build(:component, with_nano_materials: [nano_material]) }
    let(:image_upload) { create(:image_upload, :uploaded_and_virus_scanned) }

    context "when no information is missing" do
      let(:notification) { create(:draft_notification, image_uploads: [image_upload], components: [component]) }

      it "can submit a notification" do
        expect(notification).to be_may_submit_notification
      end
    end

    context "when information is missing" do
      let(:with_stubbed_antivirus_result) { false }
      let(:notification) { create(:draft_notification, image_uploads: [image_upload], components: [component]) }

      before do
        image_upload.reload
      end

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

  describe "notification submission" do
    let(:notification) { create(:notification, :draft_complete, :with_components) }
    let(:image_upload) { create(:image_upload, :uploaded_and_virus_scanned, notification:) }

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
    let(:notification) { create(:notification, :registered, :with_components, responsible_person:) }
    let(:image_upload) { create(:image_upload, :uploaded_and_virus_scanned, notification:) }
    let(:deleted_notification) { DeletedNotification.first }

    describe "#destroy" do
      it "works as #soft_delete!" do
        notification.destroy
        expect(notification.reload.state).to eq described_class::DELETED.to_s
      end
    end

    describe "#destroy!" do
      it "works as #soft_delete!" do
        notification.destroy!
        expect(notification.reload.state).to eq described_class::DELETED.to_s
      end
    end

    describe "#soft_delete!" do
      describe "deleted notification record" do
        let!(:notification_attributes) { notification.attributes }

        before { notification.soft_delete! }

        it "is created with proper attributes" do
          described_class::DELETABLE_ATTRIBUTES.each do |attribute|
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

      describe "notification that is soft deleted" do
        it "removes all attributes properly" do
          notification.soft_delete!
          notification.reload

          described_class::DELETABLE_ATTRIBUTES.each do |attribute|
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

        it "has a deletion timestamp" do
          date = Time.zone.local(2022, 11, 23, 10)
          travel_to date do
            expect { notification.soft_delete! }.to change(notification, :deleted_at).from(nil).to(date)
          end
        end

        it "does not update the deletion timestamp when called multiple times" do
          notification.soft_delete!
          expect { notification.soft_delete! }.not_to change(notification, :deleted_at)
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

      describe "document in opensearch index" do
        let(:elastic_search_double) do
          instance_double(Elasticsearch::Model::Proxy::InstanceMethodsProxy, delete_document: nil)
        end

        before do
          allow(notification).to receive(:__elasticsearch__).and_return(elastic_search_double)
        end

        it "is removed from submitted notifications" do
          notification.soft_delete!
          expect(elastic_search_double).to have_received(:delete_document).once
        end

        it "is not removed from already deleted notifications" do
          notification.soft_delete!
          notification.soft_delete!
          expect(elastic_search_double).to have_received(:delete_document).once
        end

        context "when the notification is not submitted" do
          let(:notification) { create(:draft_notification) }

          it "is not removed" do
            notification.soft_delete!
            expect(elastic_search_double).not_to have_received(:delete_document)
          end
        end
      end
    end

    describe "#hard_delete!" do
      let(:elastic_search_double) do
        instance_double(Elasticsearch::Model::Proxy::InstanceMethodsProxy, delete_document: nil)
      end

      before do
        allow(notification).to receive(:__elasticsearch__).and_return(elastic_search_double)
      end

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

      it "deletes the notification from opensearch index" do
        notification.hard_delete!
        expect(elastic_search_double).to have_received(:delete_document).once
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

        it "does not attempt to delete the notification from opensearch index" do
          notification.hard_delete!
          expect(elastic_search_double).not_to have_received(:delete_document)
        end
      end
    end
  end

  describe "#reference_number_for_display" do
    it "returns empty string if reference number is not set" do
      notification = build_stubbed(:notification, reference_number: nil)
      expect(notification.reference_number_for_display).to eq ""
    end

    it "formats the reference number" do
      notification = build_stubbed(:notification, reference_number: "60162968")
      expect(notification.reference_number_for_display).to eq "UKCP-60162968"
    end
  end

  describe "#add_image" do
    context "when fewer than 10 images are attached" do
      let(:image_uploads) { create_list(:image_upload, 8, :uploaded_and_virus_scanned) }
      let(:notification) { create(:notification, image_uploads:) }
      let(:attachment1) { fixture_file_upload("/testImage.png", "image/png") }
      let(:attachment2) { fixture_file_upload("/testImage.png", "image/png") }
      let(:attachment3) { fixture_file_upload("/testImage.png", "image/png") }

      it "allows another image to be attached" do
        notification.add_image(attachment1)
        expect { notification.save }.to(change { notification.image_uploads.count }.by(1))
      end

      it "allows two more images to be attached" do
        notification.add_image(attachment1)
        notification.add_image(attachment2)
        expect { notification.save }.to(change { notification.image_uploads.count }.by(2))
      end

      it "allows two more images to be attached but rejects the third" do
        notification.add_image(attachment1)
        notification.add_image(attachment2)
        notification.add_image(attachment3)
        expect { notification.save }.to(change { notification.image_uploads.count }.by(2))
      end
    end

    context "when 10 images are attached" do
      let(:image_uploads) { create_list(:image_upload, 10, :uploaded_and_virus_scanned) }
      let(:notification) { create(:notification, image_uploads:) }
      let(:attachment) { fixture_file_upload("/testImage.png", "image/png") }

      it "does not allow another image to be attached" do
        notification.add_image(attachment)
        expect { notification.save }.to(change { notification.image_uploads.count }.by(0))
      end

      it "sets an error message" do
        notification.add_image(attachment)
        expect(notification.errors[:image_uploads]).to eq(["You can only upload up to 10 images"])
      end
    end

    context "when a file with a disallowed extension is added" do
      let(:notification) { create(:notification) }
      let(:attachment) { fixture_file_upload("/badfile.xyz", "application/xyz") }

      it "sets an error message" do
        notification.add_image(attachment)
        expect(notification.errors[:image_uploads]).to eq(["The selected file must be a JPG, PNG or PDF"])
      end
    end

    context "when an image is too large" do
      let(:notification) { create(:notification) }
      let(:attachment) { fixture_file_upload("/testImage.png", "image/png") }

      it "sets an error message" do
        allow(attachment.tempfile).to receive(:size).and_return(31.megabytes)
        notification.add_image(attachment)

        expect(notification.errors[:image_uploads]).to eq(["The selected file must be smaller than 30MB"])
      end
    end

    context "when an uploaded file contains a virus" do
      let(:notification) { create(:notification) }
      let(:attachment) { fixture_file_upload("/testImage.png", "image/png") }

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(ImageUpload).to receive(:failed_antivirus_check?).and_return(true)
        # rubocop:enable RSpec/AnyInstance
      end

      it "sets an error message" do
        notification.add_image(attachment)

        expect(notification.errors[:image_uploads]).to eq(["The selected file contains a virus"])
      end
    end
  end

  describe "#make_ready_for_nanomaterials!" do
    subject(:make_ready) { notification.make_ready_for_nanomaterials!(count) }

    shared_examples "no changes" do
      it "returns 0 as number of nanomaterials created" do
        expect(notification.make_ready_for_nanomaterials!(count)).to eq 0
      end

      it "does not create any nanomaterials" do
        expect { notification.make_ready_for_nanomaterials!(count) }
          .not_to(change { notification.nano_materials.count })
      end

      it "does not change the notification state" do
        expect { notification.make_ready_for_nanomaterials!(count) }
        .not_to change(notification, :state)
      end
    end

    context "with a notification containing no nanomaterials" do
      let(:notification) { create(:notification) }

      context "when not given a number of nanomaterials" do
        let(:count) { nil }

        include_examples "no changes"
      end

      context "when given a non digit value as nanomaterials count" do
        let(:count) { "twelve" }

        include_examples "no changes"
      end

      context "when given 0 nanomaterials count" do
        let(:count) { 0 }

        include_examples "no changes"
      end

      context "when given a nanomaterials count" do
        let(:count) { 2 }

        it "returns 2 as the number of nanomaterials created" do
          expect(make_ready).to eq 2
        end

        it "creates the missing nanomaterials to match the given count" do
          expect { make_ready }
            .to(change { notification.nano_materials.count }.by(2))
        end

        it "sets the notification state to reay for nanomaterials" do
          expect { notification.make_ready_for_nanomaterials!(2) }
            .to change(notification, :state).to(Notification::READY_FOR_NANOMATERIALS.to_s)
        end
      end
    end

    context "with a notification containing nanomaterials" do
      let(:notification) { create(:notification, :with_nano_materials) }

      context "when not given a number of nanomaterials" do
        let(:count) { nil }

        include_examples "no changes"
      end

      context "when given a non digit value as nanomaterials count" do
        let(:count) { "twelve" }

        include_examples "no changes"
      end

      context "when given 0 nanomaterials count" do
        let(:count) { 0 }

        include_examples "no changes"
      end

      context "when given a nanomaterials count" do
        let(:count) { 3 }

        include_examples "no changes"
      end
    end
  end

  describe "#make_single_ready_for_components!" do
    subject(:make_ready) { notification.make_single_ready_for_components!(count) }

    shared_examples "nothing changes" do
      it "returns 0 as number of components created" do
        expect(make_ready).to eq 0
      end

      it "does not create any components" do
        expect { make_ready }.not_to(change { notification.components.count })
      end

      it "does not change the notification state" do
        expect { make_ready }.not_to change(notification, :state)
      end
    end

    shared_examples "sets up single component" do
      it { expect(make_ready).to eq 1 }

      it "creates a single component" do
        expect { make_ready }.to(change { notification.components.count }.by(1))
      end

      it "does not change the notification state" do
        expect { make_ready }.not_to change(notification, :state)
      end
    end

    context "with a multi component notification" do
      let(:notification) { create(:notification, :with_components) }

      context "when given a count of 0" do
        let(:count) { 0 }

        include_examples "nothing changes"
      end

      context "when given a single count" do
        let(:count) { 1 }

        include_examples "nothing changes"
      end

      context "when given a multiple count" do
        let(:count) { 3 }

        include_examples "nothing changes"
      end
    end

    context "with a single component notification" do
      let(:notification) do
        create(:notification, :with_component, state: Notification::COMPONENTS_COMPLETE, previous_state: Notification::READY_FOR_COMPONENTS)
      end

      context "when given a count of 0" do
        let(:count) { 0 }

        include_examples "nothing changes"
      end

      context "when given a single count" do
        let(:count) { 1 }

        include_examples "nothing changes"
      end

      context "when given a multiple count" do
        let(:count) { 3 }

        it "returns 2 as number of components created" do
          expect(make_ready).to eq 2
        end

        it "creates the missing components to match the given count" do
          expect { make_ready }.to(change { notification.components.count }.by(2))
        end

        it "reverts notification state to 'details complete'" do
          expect { make_ready }.to change(notification, :state).to(Notification::DETAILS_COMPLETE.to_s)
        end

        it "resets the notification previous state" do
          expect { make_ready }.to change(notification, :previous_state).to(nil)
        end
      end
    end

    context "with a notification without components" do
      let(:notification) { create(:notification, state: Notification::READY_FOR_NANOMATERIALS) }

      context "when given a count of 0" do
        let(:count) { 0 }

        include_examples "sets up single component"
      end

      context "when given a single count" do
        let(:count) { 1 }

        include_examples "sets up single component"
      end

      context "when given a multiple count" do
        let(:count) { 3 }

        it "returns 3 as number of components created" do
          expect(make_ready).to eq 3
        end

        it "creates the missing components to match the given count" do
          expect { make_ready }.to(change { notification.components.count }.by(3))
        end

        it "does not change the notification state" do
          expect { make_ready }.not_to change(notification, :state)
        end

        it " does not reset the notification previous state" do
          expect { make_ready }.not_to change(notification, :previous_state)
        end
      end
    end
  end

  describe "product name duplication validation on clone" do
    let(:name) { "Some notification" }
    let(:notification) { create(:notification, product_name: name) }
    let(:responsible_person) { notification.responsible_person }
    let(:new_notification) { build(:notification, responsible_person:, product_name: new_name) }

    shared_examples_for "product name validation" do
      before do
        notification
      end

      it "allows a duplicate name" do
        expect(new_notification.valid?(:cloning)).to eq true
      end
    end

    context "when new name is the same" do
      let(:new_name) { name }

      it_behaves_like "product name validation"
    end

    context "when new name is the same with extra spaces" do
      let(:new_name) { " #{name} " }

      it_behaves_like "product name validation"
    end

    context "when new name is the same but with different case" do
      let(:new_name) { "some Notification" }

      it_behaves_like "product name validation"
    end

    context "when responsible person is different" do
      let(:new_name) { name }
      let(:responsible_person) { create(:responsible_person) }

      it_behaves_like "product name validation"
    end
  end

  describe "#editable?" do
    it "is true for EDITABLE_STATES" do
      Notification::EDITABLE_STATES.each do |state|
        expect(build(:notification, state:)).to be_editable
      end
    end

    it "is false for complete/deleted states" do
      [Notification::NOTIFICATION_COMPLETE, Notification::DELETED].each do |state|
        expect(build(:notification, state:)).not_to be_editable
      end
    end
  end

  describe "versioning", versioning: true do
    context "when transitioning state from draft to complete" do
      let(:notification) { create(:draft_notification) }

      it "does not create a new version" do
        expect(notification.versions_with_name.length).to eq(0)
        notification.submit_notification!
        expect(notification.versions_with_name.length).to eq(0)
      end
    end

    context "when transitioning state from complete to archived" do
      let(:notification) { create(:registered_notification) }

      before do
        notification
        described_class.import_to_opensearch(force: true)
      end

      it "creates a new version" do
        expect(notification.versions_with_name.length).to eq(0)
        notification.assign_attributes(archive_reason: "significant_change_to_the_formulation")
        notification.archive
        expect(notification.versions_with_name.length).to eq(1)
      end
    end

    context "when transitioning state from archived to complete" do
      let(:notification) { create(:registered_notification) }

      before do
        notification
        described_class.import_to_opensearch(force: true)
      end

      it "creates a new version" do
        notification.assign_attributes(archive_reason: "significant_change_to_the_formulation")
        notification.archive
        expect(notification.versions_with_name.length).to eq(1)
        notification.unarchive
        expect(notification.versions_with_name.length).to eq(2)
      end
    end
  end
end
