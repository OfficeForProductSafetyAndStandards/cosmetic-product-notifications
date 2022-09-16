require "rails_helper"

Rails.application.load_tasks

describe "nanomaterials.rake" do
  before do
    allow($stdout).to receive(:puts) # Silence console output while testing tasks
  end

  describe ":delete_nanomaterials_without_nanoelements" do
    subject(:task) { Rake::Task["nanomaterials:delete_nanomaterials_without_nanoelements"] }

    it "deletes any nano material without an associated nano element" do
      create_list(:nano_material, 2)
      nano_with_element = create(:nano_element).nano_material

      expect { task.invoke }.to change(NanoMaterial, :count).by(-2)
      expect(NanoMaterial.all).to include(nano_with_element)
    end

    it "does not delet nano materials with associated nano elements" do
      nano = create(:nano_element).nano_material

      expect { task.invoke }.not_to change(NanoMaterial, :count)
      expect(NanoMaterial.all).to eq [nano]
    end
  end

  describe ":delete_orphan_nanomaterials" do
    subject(:task) { Rake::Task["nanomaterials:delete_orphan_nanomaterials"] }

    it "deletes any nano materials without an associated component or notification" do
      create_list(:nano_material, 2, :skip_validations, component_id: nil, notification_id: nil)

      expect { task.invoke }.to change(NanoMaterial, :count).by(-2)
    end

    it "does not delete nanomaterials with an associated notification" do
      nano = create(:nano_material, component_id: nil)

      expect { task.invoke }.not_to change(NanoMaterial, :count)
      expect(NanoMaterial.all).to eq [nano]
    end

    it "does not delete nanomaterials with a deprecated reference to component id" do
      component = create(:component)
      nano = create(:nano_material, :skip_validations, notification_id: nil, component_id: component.id)

      expect { task.invoke }.not_to change(NanoMaterial, :count)
      expect(NanoMaterial.all).to eq [nano]
    end

    it "does not delete nanomaterials with an associated component" do
      nano = create(:nano_material, :skip_validations, notification_id: nil, component_id: nil)
      nano.components << create(:component)

      expect { task.invoke }.not_to change(NanoMaterial, :count)
      expect(NanoMaterial.all).to eq [nano]
    end
  end
end
