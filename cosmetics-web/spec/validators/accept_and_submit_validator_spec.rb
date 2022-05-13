require "rails_helper"

RSpec.describe AcceptAndSubmitValidator, :with_stubbed_antivirus do
  let(:nano_name) { "Nano 1" }

  let(:notification) { create(:notification) }
  let(:component) { create(:component, notification: notification) }
  let(:nano_material) { create(:nano_material, notification: notification) }
  let(:nano_element) { create(:nano_element, inci_name: nano_name, nano_material: nano_material) }
  let(:image_upload) { create(:image_upload, :uploaded_and_virus_scanned, notification: notification) }

  before do
    nano_element
    component
    image_upload

    notification.valid?(:accept_and_submit)
  end

  describe "missing nanomaterials" do
    it "complains about missing nanomaterial" do
      expect(notification.errors.messages_for(:nano_materials)).to eq(["#{nano_name} is not included in any items"])
    end
  end

  describe "image failed antivirus check" do
    let(:with_stubbed_antivirus_result) { false }
    let(:image_upload) { create(:image_upload, :uploaded_and_virus_identified, notification: notification) }

    it "complains about image" do
      expect(notification.errors.messages_for(:image_uploads)).to eq(["Image #{image_upload.filename} failed antivirus check. Remove image and try again"])
    end
  end

  describe "image still being processed" do
    let(:with_stubbed_antivirus_result) { nil }
    let(:image_upload) { create(:image_upload, notification: notification) }

    it "complains about image" do
      expect(notification.errors.messages_for(:image_uploads)).to eq(["Image #{image_upload.filename} is still being processed"])
    end
  end

  describe "formulation file failed antivirus check" do
    let(:with_stubbed_antivirus_result) { false }
    let(:component) { create(:component, :with_formulation_file, notification: notification) }

    it "complains about file" do
      expect(notification.errors.messages_for(:formulation_uploads)).to eq(["File #{component.formulation_file.filename} failed antivirus check. Remove file and try again"])
    end
  end

  describe "formulation file still being processed" do
    let(:with_stubbed_antivirus_result) { nil }
    let(:component) { create(:component, :with_formulation_file, notification: notification) }

    it "complains about file" do
      expect(notification.errors.messages_for(:formulation_uploads)).to eq(["File #{component.formulation_file.filename} is still being processed"])
    end
  end

  describe "formulation file is missing" do
    let(:component) { create(:ranges_component, name: "Item 1", notification: notification) } # ranges component requires file

    it "complains about missing file" do
      expect(notification.errors.messages_for(:formulation_uploads)).to eq(["Item #{component.name} is missing formulation file"])
    end
  end
end
