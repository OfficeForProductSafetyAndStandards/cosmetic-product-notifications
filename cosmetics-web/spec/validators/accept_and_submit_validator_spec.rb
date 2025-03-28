require "rails_helper"

RSpec.describe AcceptAndSubmitValidator, :with_stubbed_antivirus do
  let(:nano_name) { "Nano 1" }

  let(:notification) { create(:notification) }
  let(:component) { create(:component, notification:) }
  let(:nano_material) { create(:nano_material, notification:, inci_name: nano_name) }
  let(:image_upload) { create(:image_upload, :uploaded_and_virus_scanned, notification:) }

  before do
    nano_material
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
    let(:image_upload) { create(:image_upload, :uploaded_and_virus_identified, notification:) }

    it "complains about image" do
      expect(notification.errors.messages_for(:image_uploads)).to eq(["Image #{image_upload.filename} failed virus scan; remove the image and try again"])
    end
  end

  describe "image is missing" do
    before do
      ImageUpload.delete_all

      notification.reload.valid?(:accept_and_submit)
    end

    it "complains about missing image" do
      expect(notification.errors.messages_for(:image_uploads)).to eq(["Product image is missing"])
    end
  end

  describe "image still being processed" do
    let(:image_upload) { create(:image_upload, notification:) }

    # Create an image that's not yet been scanned
    before do
      # Make sure the file is attached but has no metadata
      image_upload.file.blob.metadata = {}
      image_upload.file.blob.save!

      notification.reload.valid?(:accept_and_submit)
    end

    it "complains about image" do
      expect(image_upload.pending_antivirus_check?).to be true
      expect(notification.errors.messages_for(:image_uploads)).to eq(["Image #{image_upload.filename} is pending virus scan"])
    end
  end

  describe "formulation ingredients are missing for the component" do
    let(:component) { create(:component, :using_range, notification:) }

    before do
      allow(component).to receive(:missing_ingredients?).and_return(true)
    end

    it "complains about file" do
      expect(notification.errors.messages_for(:formulation_uploads)).to eq(["The notification has not listed any ingredients"])
    end
  end

  describe "Ingredient name is too long" do
    let(:name) do
      "X" * (Ingredient::NAME_LENGTH_LIMIT * 2)
    end

    let(:ingredient) { create(:range_ingredient) }
    let(:component) { create(:component, :using_range, notification:, ingredients: [ingredient]) }

    before do
      ingredient.inci_name = name
      ingredient.save(validate: false)

      notification.valid?(:accept_and_submit)
    end

    it "complains about too long ingredient name" do
      expect(notification.errors.messages_for(:ingredients)).to eq(["Ingredient names must be 100 characters or less"])
    end
  end
end
