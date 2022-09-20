require "rails_helper"

Rails.application.load_tasks

describe "nanomaterials.rake" do
  before do
    allow(Rails.logger).to receive(:info) # Silence logging while testing tasks
  end

  after do
    task&.reenable # Reenable task so it can be invoked again in another test
  end

  describe ":delete_nanomaterials_without_nanoelements" do
    subject(:task) { Rake::Task["nanomaterials:delete_nanomaterials_without_nanoelements"] }

    it "deletes any nano material without an associated nano element" do
      create_list(:nano_material, 2)
      nano_with_element = create(:nano_element).nano_material

      expect { task.invoke }.to change(NanoMaterial, :count).by(-2)
      expect(NanoMaterial.all).to include(nano_with_element)
    end

    it "does not delete nano materials with associated nano elements" do
      nano = create(:nano_element).nano_material

      expect { task.invoke }.not_to change(NanoMaterial, :count)
      expect(NanoMaterial.all).to eq [nano]
    end
  end

  describe ":delete_orphan_nanomaterials" do
    subject(:task) { Rake::Task["nanomaterials:delete_orphan_nanomaterials"] }

    it "deletes any nano materials without an associated component or notification" do
      create_list(:nano_material, 2, :skip_validations, notification_id: nil)

      expect { task.invoke }.to change(NanoMaterial, :count).by(-2)
    end

    it "does not delete nanomaterials with an associated notification" do
      nano = create(:nano_material)

      expect { task.invoke }.not_to change(NanoMaterial, :count)
      expect(NanoMaterial.all).to eq [nano]
    end

    it "does not delete nanomaterials with an associated component" do
      nano = create(:nano_material, :skip_validations, notification_id: nil)
      nano.components << create(:component)

      expect { task.invoke }.not_to change(NanoMaterial, :count)
      expect(NanoMaterial.all).to eq [nano]
    end
  end

  describe ":single_nanoelement_per_nanomaterial" do
    subject(:task) { Rake::Task["nanomaterials:single_nanoelement_per_nanomaterial"] }

    context "when a single nanomaterial has multiple nanoelements" do
      let(:nano_material) { create(:nano_material) }
      let(:component) { create(:component, notification: nano_material.notification) }
      let(:nano_element1) { create(:nano_element, nano_material:) }
      let(:nano_element2) { create(:nano_element, nano_material:) }

      before do
        travel_to 1.month.ago do
          nano_material
          nano_material.components << component
          nano_element1
          nano_element2
        end
      end

      # rubocop:disable RSpec/ExampleLength
      it "creates a new nanomaterial with the same values as the original" do
        expect { task.invoke }.to change(NanoMaterial, :count).by(1)
        new_nano_material = NanoMaterial.last
        expect(new_nano_material).to have_attributes(
          exposure_condition: nano_material.exposure_condition,
          exposure_routes: nano_material.exposure_routes,
          notification_id: nano_material.notification_id,
          created_at: nano_material.created_at,
          updated_at: nano_material.updated_at,
        )
      end
      # rubocop:enable RSpec/ExampleLength

      it "associates the new nanomaterial with the same components as the original" do
        expect { task.invoke }.to change(ComponentNanoMaterial, :count).by(1)
        expect(ComponentNanoMaterial.last).to have_attributes(component:, nano_material: NanoMaterial.last)
      end

      it "keeps the original association of the first nanoelement" do
        expect {
          task.invoke
          nano_material.reload
        }.to change(nano_material, :nano_elements).from([nano_element1, nano_element2]).to([nano_element1])
        expect(nano_element1.nano_material).to eq(nano_material)
      end

      it "associates the second nanoelement with the new nanomaterial" do
        task.invoke
        new_nanomaterial = NanoMaterial.last
        expect(new_nanomaterial).not_to eq nano_material
        expect(nano_element2.reload.nano_material).to eq(new_nanomaterial)
      end
    end
  end
end
