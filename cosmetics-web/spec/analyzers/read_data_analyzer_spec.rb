require "rails_helper"

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
      expect(described_class.accept?(nil)).equal?(false)
    end

    it "accepts a zip blob" do
      expect(described_class.accept?(notification_file_basic.uploaded_file)).equal?(true)
    end
  end

  describe "#metadata" do
    it "creates a notification and removes a notification file" do
      analyzer_instance = described_class.new(notification_file_basic.uploaded_file)
      expect {
        analyzer_instance.metadata
      }.to change(Notification, :count).by(1).and change(NotificationFile, :count).by(-1)
    end

    it "creates a notification populated with relevant name" do
      analyzer_instance = described_class.new(notification_file_basic.uploaded_file)
      analyzer_instance.metadata
      notification = Notification.order(created_at: :asc).last

      expect(notification.product_name).equal?("CTPA moisture conditioner")
    end

    context "when the file contains a post-Brexit date" do
      let(:notification_file) { create(:notification_file, uploaded_file: create_file_blob("testExportFilePostBrexit.zip")) }

      before do
        analyzer_instance = described_class.new(notification_file.uploaded_file)
        analyzer_instance.metadata
      end

      it "adds an error to the file" do
        expect(notification_file.reload.upload_error).to eq("post_brexit_date")
      end
    end
  end
end
