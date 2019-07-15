require 'rails_helper'

RSpec.describe ReadDataAnalyzer, type: :analyzer do
  let(:responsible_person) { create(:responsible_person) }
  let(:notification_file_basic) { create(:notification_file, uploaded_file: create_file_blob) }
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

  describe "#accept" do
    it "rejects a null blob" do
      expect(ReadDataAnalyzer.accept?(nil)).equal?(false)
    end

    it "accepts a zip blob" do
      expect(ReadDataAnalyzer.accept?(notification_file_basic.uploaded_file)).equal?(true)
    end
  end

  describe "#metadata" do
    it "creates a notification and removes a notification file" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_basic.uploaded_file)
      expect {
        analyzer_instance.metadata
      }.to change(Notification, :count).by(1).and change(NotificationFile, :count).by(-1)
    end

    it "creates a notification populated with relevant name" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_basic.uploaded_file)
      analyzer_instance.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.product_name).equal?("CTPA moisture conditioner")
    end

    it "creates a notification populated with relevant cpnp reference" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_basic.uploaded_file)
      analyzer_instance.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.cpnp_reference).equal?("1000094")
    end

    it "creates a notification populated with relevant cpnp date" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_basic.uploaded_file)
      analyzer_instance.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.cpnp_notification_date.to_s).equal?("2012-02-08 16:02:34 UTC")
    end

    it "creates a notification populated with relevant shades" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_shades_import.uploaded_file)
      analyzer_instance.metadata

      notification = Notification.order(created_at: :asc).last

      expect(notification.shades).equal?("red yellow pink blue")
    end

    it "creates a notification populated with relevant imported info" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_shades_import.uploaded_file)
      analyzer_instance.metadata

      notification = Notification.order(created_at: :asc).last

      expect(notification.cpnp_is_imported).equal?(true)
      expect(notification.cpnp_imported_country).equal?("country:NZ")
    end

    it "creates a notification populated with relevant number of components" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_multi_component_exact_formula.uploaded_file)

      expect {
        analyzer_instance.metadata
      }.to change(Component, :count).by(2)
    end

    it "creates a notification with components in the component_complete state" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_basic.uploaded_file)
      analyzer_instance.metadata

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.state).to eq("component_complete")
    end

    it "creates a notification populated with relevant notification type" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_basic.uploaded_file)
      analyzer_instance.metadata

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.notification_type).equal?('predefined')
    end

    it "creates a notification populated with relevant sub-sub-category" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_basic.uploaded_file)
      analyzer_instance.metadata

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.sub_sub_category).equal?('Hair conditioner')
    end

    it "creates a notification populated with relevant number of trigger questions and trigger elements" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_manual_ranges_trigger_rules.uploaded_file)

      expect {
        analyzer_instance.metadata
      }.to change(TriggerQuestion, :count).by(5).and change(TriggerQuestionElement, :count).by(6)
    end

    it "creates a notification populated with relevant frame formulation" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_basic.uploaded_file)
      analyzer_instance.metadata

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.frame_formulation).equal?('Hair Conditioner')
    end

    it "creates a notification populated with relevant number of exact formula" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_multi_component_exact_formula.uploaded_file)
      expect {
        analyzer_instance.metadata
      }.to change(ExactFormula, :count).by(4)
    end

    it "creates a notification populated with relevant number of range formula" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_manual_ranges_trigger_rules.uploaded_file)
      expect {
        analyzer_instance.metadata
      }.to change(RangeFormula, :count).by(2)
    end

    it "creates a notification populated with relevant number of cmr" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_nano_materials_cmr.uploaded_file)
      expect {
        analyzer_instance.metadata
      }.to change(Cmr, :count).by(2)
    end

    it "creates a notification populated with relevant number of nanomaterials and nanoelement" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_nano_materials_cmr.uploaded_file)
      expect {
        analyzer_instance.metadata
      }.to change(NanoMaterial, :count).by(1).and change(NanoElement, :count).by(1)
    end

    it "creates a notification in the draft_complete state if no formulation information is needed" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_basic.uploaded_file)
      analyzer_instance.metadata

      notification = Notification.order(created_at: :asc).last

      expect(notification.state).to eq("draft_complete")
    end

    it "creates a notification in the notification_file_imported state if formulation information is required" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_formulation_required.uploaded_file)
      analyzer_instance.metadata

      notification = Notification.order(created_at: :asc).last

      expect(notification.state).to eq("notification_file_imported")
    end

    it "creates a notification with the first language's name if there is no english name" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_different_language.uploaded_file)
      analyzer_instance.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.product_name).to eq("Multiple product test")
    end

    it "creates a notification with the first language's shades if there is no english shades" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_different_language.uploaded_file)
      analyzer_instance.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.shades).to eq("yellow, orange, purple")
    end

    it "creates a notification with the first language's component name if there is no english component name" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_different_language.uploaded_file)
      analyzer_instance.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.name).to eq("A")
      expect(notification.components.second.name).to eq("B")
    end

    it "creates a notification with the first language's component shades if there is no english component shades" do
      analyzer_instance = ReadDataAnalyzer.new(notification_file_different_language.uploaded_file)
      analyzer_instance.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.shades.first).to eq("blue, green")
      expect(notification.components.second.shades.first).to eq("pink, lazuli")
    end
  end
end
