require "rails_helper"

RSpec.describe NotificationFileProcessorJob do
  let(:responsible_person) { create(:responsible_person) }
  let!(:notification_file_basic) { create(:notification_file, uploaded_file: create_file_blob) }
  let(:notification_file_shades_import) { create(:notification_file, uploaded_file: create_file_blob("testWithShadesAndImport.zip")) }
  let(:notification_file_multi_component_exact_formula) { create(:notification_file, uploaded_file: create_file_blob("testMultiComponentExactFormula.zip")) }
  let(:notification_file_manual_ranges_trigger_rules) { create(:notification_file, uploaded_file: create_file_blob("testManualRangesTriggerRules.zip")) }
  let(:notification_file_nano_materials_cmr) { create(:notification_file, uploaded_file: create_file_blob("testWithNanomaterialsAndCmrs.zip")) }
  let(:notification_file_formulation_required) { create(:notification_file, uploaded_file: create_file_blob("testFormulationRequiredExportFile.zip")) }
  let(:notification_file_different_language) { create(:notification_file, uploaded_file: create_file_blob("testDifferentLanguage.zip")) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
    remove_uploaded_files
    close_file
  end

  describe "#perform" do
    it "creates a notification and removes a notification file" do
      expect {
        described_class.new.perform(notification_file_basic.id)
      }.to change(Notification, :count).by(1).and change(NotificationFile, :count).by(-1)
    end

    it "creates a notification populated with relevant name" do
      described_class.new.perform(notification_file_basic.id)
      notification = Notification.order(created_at: :asc).last
      expect(notification.product_name).equal?("CTPA moisture conditioner")
    end

    it "creates a notification populated with relevant cpnp reference" do
      described_class.new.perform(notification_file_basic.id)
      notification = Notification.order(created_at: :asc).last

      expect(notification.cpnp_reference).equal?("1000094")
    end

    it "creates a notification populated with relevant cpnp date" do
      described_class.new.perform(notification_file_basic.id)
      notification = Notification.order(created_at: :asc).last

      expect(notification.cpnp_notification_date.to_s).equal?("2012-02-08 16:02:34 UTC")
    end

    it "creates a notification populated with relevant shades" do
      described_class.new.perform(notification_file_shades_import.id)

      notification = Notification.order(created_at: :asc).last

      expect(notification.shades).equal?("red yellow pink blue")
    end

    it "creates a notification populated with relevant imported info" do
      described_class.new.perform(notification_file_shades_import.id)

      notification = Notification.order(created_at: :asc).last

      expect(notification.cpnp_is_imported).equal?(true)
      expect(notification.cpnp_imported_country).equal?("country:NZ")
    end

    it "creates a notification populated with relevant number of components" do
      expect {
        described_class.new.perform(notification_file_multi_component_exact_formula.id)
      }.to change(Component, :count).by(2)
    end

    it "creates a notification with components in the component_complete state" do
      described_class.new.perform(notification_file_basic.id)

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.state).to eq("component_complete")
    end

    it "creates a notification populated with relevant notification type" do
      described_class.new.perform(notification_file_basic.id)

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.notification_type).equal?("predefined")
    end

    it "creates a notification populated with relevant sub-sub-category" do
      described_class.new.perform(notification_file_basic.id)

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.sub_sub_category).equal?("Hair conditioner")
    end

    it "creates a notification populated with relevant number of trigger questions and trigger elements" do
      expect {
        described_class.new.perform(notification_file_manual_ranges_trigger_rules.id)
      }.to change(TriggerQuestion, :count).by(5).and change(TriggerQuestionElement, :count).by(6)
    end

    it "creates a notification populated with relevant frame formulation" do
      described_class.new.perform(notification_file_basic.id)

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.frame_formulation).equal?("Hair Conditioner")
    end

    it "creates a notification populated with relevant number of exact formula" do
      expect {
        described_class.new.perform(notification_file_multi_component_exact_formula.id)
      }.to change(ExactFormula, :count).by(4)
    end

    it "creates a notification populated with relevant number of range formula" do
      expect {
        described_class.new.perform(notification_file_manual_ranges_trigger_rules.id)
      }.to change(RangeFormula, :count).by(2)
    end

    it "creates a notification populated with relevant number of cmr" do
      expect {
        described_class.new.perform(notification_file_nano_materials_cmr.id)
      }.to change(Cmr, :count).by(2)
    end

    it "creates a notification populated with relevant number of nanomaterials and nanoelement" do
      expect {
        described_class.new.perform(notification_file_nano_materials_cmr.id)
      }.to change(NanoMaterial, :count).by(1).and change(NanoElement, :count).by(1)
    end

    it "creates a notification in the draft_complete state if no formulation information is needed" do
      described_class.new.perform(notification_file_basic.id)

      notification = Notification.order(created_at: :asc).last

      expect(notification.state).to eq("draft_complete")
    end

    it "creates a notification in the notification_file_imported state if formulation information is required" do
      described_class.new.perform(notification_file_formulation_required.id)
      notification = Notification.order(created_at: :asc).last

      expect(notification.state).to eq("notification_file_imported")
    end

    it "creates a notification with the first language's name if there is no english name" do
      described_class.new.perform(notification_file_different_language.id)
      notification = Notification.order(created_at: :asc).last

      expect(notification.product_name).to eq("Multiple product test")
    end

    it "creates a notification with the first language's shades if there is no english shades" do
      described_class.new.perform(notification_file_different_language.id)
      notification = Notification.order(created_at: :asc).last

      expect(notification.shades).to eq("yellow, orange, purple")
    end

    it "creates a notification with the first language's component name if there is no english component name" do
      described_class.new.perform(notification_file_different_language.id)
      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.name).to eq("A")
      expect(notification.components.second.name).to eq("B")
    end

    it "creates a notification with the first language's component shades if there is no english component shades" do
      described_class.new.perform(notification_file_different_language.id)
      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.shades.first).to eq("blue, green")
      expect(notification.components.second.shades.first).to eq("pink, lazuli")
    end


    context "when the file contains a component with a PH range" do
      before do
        notification_file = create(:notification_file, uploaded_file: create_file_blob("testExportWithComponentWithPHRange.zip"))

        described_class.new.perform(notification_file.id)
      end

      let(:notification) { Notification.order(created_at: :asc).last }

      it "sets the ph range to above_10" do
        expect(notification.components.first.ph).to eq("above_10")
      end

      it "imports the minimum PH" do
        expect(notification.components.first.minimum_ph).to eq(13.0)
      end

      it "imports the maximum PH" do
        expect(notification.components.first.maximum_ph).to eq(14.0)
      end
    end

    context "when the file contains a component with a single PH value" do
      before do
        notification_file = create(:notification_file, uploaded_file: create_file_blob("testExportWithComponentWithSinglePHValue.zip"))

        described_class.new.perform(notification_file.id)
      end

      let(:notification) { Notification.order(created_at: :asc).last }

      it "sets the component pH to lower_than_3" do
        expect(notification.components.first.ph).to eq("lower_than_3")
      end

      it "imports the single PH value as the minimum pH" do
        expect(notification.components.first.minimum_ph).to eq(2.0)
      end

      it "imports the single PH value as the maximum pH" do
        expect(notification.components.first.maximum_ph).to eq(2.0)
      end
    end

    context "when the file contains a post-Brexit date" do
      let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testExportFilePostBrexit.zip")) }

      before do
        described_class.new.perform(notification_file.id)
      end

      it "adds an error to the file" do
        expect(notification_file.reload.upload_error).to eq("post_brexit_date")
      end
    end
  end
end
