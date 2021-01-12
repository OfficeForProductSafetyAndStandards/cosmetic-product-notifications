require "rails_helper"
require "zip"

RSpec.describe CpnpNotificationImporter do
  let(:responsible_person) { create(:responsible_person) }

  let(:cpnp_parser_basic) { create_cpnp_parser }
  let(:cpnp_parser_shades_import) { create_cpnp_parser("testWithShadesAndImport.zip") }
  let(:cpnp_parser_component_validation) { create_cpnp_parser("testNameValidationMultiComponent.zip") }
  let(:cpnp_parser_multi_component_exact_formula) { create_cpnp_parser("testMultiComponentExactFormula.zip") }
  let(:cpnp_parser_manual_ranges_trigger_rules) { create_cpnp_parser("testManualRangesTriggerRules.zip") }
  let(:cpnp_parser_nano_materials_cmr) { create_cpnp_parser("testWithNanomaterialsAndCmrs.zip") }
  let(:cpnp_parser_formulation_not_required) { create_cpnp_parser("testFormulationRequiredExportFile.zip") }
  let(:cpnp_parser_formulation_required) { create_cpnp_parser("testFormulationRequiredExportFilePostExit.zip") }
  let(:cpnp_parser_before_exit) { create_cpnp_parser("testFormulationRequiredExportFile.zip") }
  let(:cpnp_parser_after_exit) { create_cpnp_parser("testFormulationRequiredExportFilePostExit.zip") }
  let(:cpnp_parser_different_language) { create_cpnp_parser("testDifferentLanguage.zip") }

  describe "#create!" do
    # TODO: This should be tested in different spec, possibly ReadDataAnalyzer
    #
    # it "creates a notification and removes a notification file" do
    #   exporter_instance = described_class.new(cpnp_parser_basic)
    #   expect {
    #     exporter_instance.create!
    #   }.to change(Notification, :count).by(1).and change(NotificationFile, :count).by(-1)
    # end

    it "creates a notification populated with relevant name" do
      exporter_instance = described_class.new(cpnp_parser_basic, responsible_person)

      exporter_instance.create!
      notification = Notification.order(created_at: :asc).last

      expect(notification.product_name).equal?("CTPA moisture conditioner")
    end

    it "skips component name validation" do
      exporter_instance = described_class.new(cpnp_parser_component_validation, responsible_person)

      exporter_instance.create!
      notification = Notification.order(created_at: :asc).last

      expect(notification.product_name).equal?("CTPA moisture conditioner")
    end

    it "creates a notification populated with relevant cpnp reference" do
      exporter_instance = described_class.new(cpnp_parser_basic, responsible_person)
      exporter_instance.create!
      notification = Notification.order(created_at: :asc).last

      expect(notification.cpnp_reference).equal?("1000094")
    end

    it "creates a notification populated with relevant cpnp date" do
      exporter_instance = described_class.new(cpnp_parser_basic, responsible_person)
      exporter_instance.create!
      notification = Notification.order(created_at: :asc).last

      expect(notification.cpnp_notification_date.to_s).equal?("2012-02-08 16:02:34 UTC")
    end

    it "creates a notification populated with relevant shades" do
      exporter_instance = described_class.new(cpnp_parser_shades_import, responsible_person)
      exporter_instance.create!

      notification = Notification.order(created_at: :asc).last

      expect(notification.shades).equal?("red yellow pink blue")
    end

    it "creates a notification populated with relevant number of components" do
      exporter_instance = described_class.new(cpnp_parser_multi_component_exact_formula, responsible_person)

      expect {
        exporter_instance.create!
      }.to change(Component, :count).by(2)
    end

    it "creates a notification when orphaned component exists" do
      # create(:component, name: 'A', notification: nil)
      exporter_instance = described_class.new(cpnp_parser_multi_component_exact_formula, responsible_person)

      expect {
        exporter_instance.create!
      }.to change(Notification, :count).by(1)
    end

    it "creates a notification with components in the component_complete state" do
      exporter_instance = described_class.new(cpnp_parser_basic, responsible_person)
      exporter_instance.create!

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.state).to eq("component_complete")
    end

    it "creates a notification populated with relevant notification type" do
      exporter_instance = described_class.new(cpnp_parser_basic, responsible_person)
      exporter_instance.create!

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.notification_type).equal?("predefined")
    end

    it "creates a notification populated with relevant sub-sub-category" do
      exporter_instance = described_class.new(cpnp_parser_basic, responsible_person)
      exporter_instance.create!

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.sub_sub_category).equal?("Hair conditioner")
    end

    it "creates a notification populated with relevant number of trigger questions and trigger elements" do
      exporter_instance = described_class.new(cpnp_parser_manual_ranges_trigger_rules, responsible_person)

      expect {
        exporter_instance.create!
      }.to change(TriggerQuestion, :count).by(5).and change(TriggerQuestionElement, :count).by(6)
    end

    it "creates a notification populated with relevant frame formulation" do
      exporter_instance = described_class.new(cpnp_parser_basic, responsible_person)
      exporter_instance.create!

      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.frame_formulation).equal?("Hair Conditioner")
    end

    it "creates a notification populated with relevant number of exact formula" do
      exporter_instance = described_class.new(cpnp_parser_multi_component_exact_formula, responsible_person)
      expect {
        exporter_instance.create!
      }.to change(ExactFormula, :count).by(4)
    end

    it "creates a notification populated with relevant number of range formula" do
      exporter_instance = described_class.new(cpnp_parser_manual_ranges_trigger_rules, responsible_person)
      expect {
        exporter_instance.create!
      }.to change(RangeFormula, :count).by(2)
    end

    it "creates a notification populated with relevant number of cmr" do
      exporter_instance = described_class.new(cpnp_parser_nano_materials_cmr, responsible_person)
      expect {
        exporter_instance.create!
      }.to change(Cmr, :count).by(2)
    end

    it "creates a notification populated with relevant number of nanomaterials and nanoelement" do
      exporter_instance = described_class.new(cpnp_parser_nano_materials_cmr, responsible_person)
      expect {
        exporter_instance.create!
      }.to change(NanoMaterial, :count).by(1).and change(NanoElement, :count).by(1)
    end

    it "creates a notification in the draft_complete state if no formulation information is needed" do
      exporter_instance = described_class.new(cpnp_parser_basic, responsible_person)
      exporter_instance.create!

      notification = Notification.order(created_at: :asc).last

      expect(notification.state).to eq("draft_complete")
    end

    it "creates a notification in the notification_file_imported state if formulation information is not required" do
      exporter_instance = described_class.new(cpnp_parser_formulation_not_required, responsible_person)
      exporter_instance.create!

      notification = Notification.order(created_at: :asc).last

      expect(notification.state).to eq("draft_complete")
    end

    it "creates a notification in the notification_file_imported state if formulation information is required" do
      exporter_instance = described_class.new(cpnp_parser_formulation_required, responsible_person)
      exporter_instance.create!

      notification = Notification.order(created_at: :asc).last

      expect(notification.state).to eq("notification_file_imported")
    end

    it "creates a notification with was_notified_before_eu_exit set to true" do
      exporter_instance = described_class.new(cpnp_parser_before_exit, responsible_person)
      exporter_instance.create!

      notification = Notification.order(created_at: :asc).last

      expect(notification.was_notified_before_eu_exit).to be_truthy
    end

    it "creates a notification with was_notified_before_eu_exit set to false" do
      exporter_instance = described_class.new(cpnp_parser_after_exit, responsible_person)
      exporter_instance.create!

      notification = Notification.order(created_at: :asc).last

      expect(notification.was_notified_before_eu_exit).to be_falsey
    end

    it "creates a notification with the first language's name if there is no english name" do
      exporter_instance = described_class.new(cpnp_parser_different_language, responsible_person)
      exporter_instance.create!
      notification = Notification.order(created_at: :asc).last

      expect(notification.product_name).to eq("Multiple product test")
    end

    it "creates a notification with the first language's shades if there is no english shades" do
      exporter_instance = described_class.new(cpnp_parser_different_language, responsible_person)
      exporter_instance.create!
      notification = Notification.order(created_at: :asc).last

      expect(notification.shades).to eq("yellow, orange, purple")
    end

    it "creates a notification with the first language's component name if there is no english component name" do
      exporter_instance = described_class.new(cpnp_parser_different_language, responsible_person)
      exporter_instance.create!
      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.name).to eq("A")
      expect(notification.components.second.name).to eq("B")
    end

    it "creates a notification with the first language's component shades if there is no english component shades" do
      exporter_instance = described_class.new(cpnp_parser_different_language, responsible_person)
      exporter_instance.create!
      notification = Notification.order(created_at: :asc).last

      expect(notification.components.first.shades.first).to eq("blue, green")
      expect(notification.components.second.shades.first).to eq("pink, lazuli")
    end

    context "when the file contains a component with a PH range" do
      before do
        cpnp_parser = create_cpnp_parser("testExportWithComponentWithPHRange.zip")

        exporter_instance = described_class.new(cpnp_parser, responsible_person)
        exporter_instance.create!
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
        cpnp_parser = create_cpnp_parser("testExportWithComponentWithSinglePHValue.zip")

        exporter_instance = described_class.new(cpnp_parser, responsible_person)
        exporter_instance.create!
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
  end

  def create_cpnp_parser(filename = "testExportFile.zip")
    path = Rails.root.join("spec", "fixtures", filename)
    Zip::File.open(path) do |files|
      files.each do |file|
        name_regexp = /[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}.*\.xml/
        if file.name&.match?(name_regexp)
          return CpnpParser.new(file.get_input_stream.read)
        end
      end
    end
  end
end
