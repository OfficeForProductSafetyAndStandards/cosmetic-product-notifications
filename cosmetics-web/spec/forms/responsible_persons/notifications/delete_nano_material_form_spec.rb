require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::DeleteNanoMaterialForm do
  let(:notification1) { create(:notification) }
  let(:nano_material1) { create(:nano_material, notification: notification1) }

  let(:notification2) { create(:notification) }
  let(:nano_material2) { create(:nano_material, notification: notification2) }

  describe "validation" do
    context "when nano_material_ids attribute is missing" do
      it "is invalid" do
        expect(described_class.new).not_to be_valid
      end
    end

    context "when nano_material_ids attribute is blank" do
      let(:form) { described_class.new(notification: notification1, nano_material_ids: []) }

      it "is invalid" do
        expect(form).not_to be_valid
      end
    end

    context "when nano_material_ids attribute has blank elements" do
      let(:form) { described_class.new(notification: notification1, nano_material_ids: [""]) }

      it "is invalid" do
        expect(form).not_to be_valid
      end
    end
  end

  describe "#delete" do
    context "when form is invalid" do
      let(:form) { described_class.new(notification: notification1) }

      it "returns false if form is invalid" do
        expect(form.delete).to eq false
      end
    end

    context "when nano_material can not be found" do
      let(:form) { described_class.new(notification: notification1, nano_material_ids: [1]) }

      it "raises ActiveRecord::ElementNotFound" do
        expect(NanoMaterial.count).to eq 0 # to make sure no nano_materials are present

        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when nano_material does not belong to notification" do
      let(:form) { described_class.new(notification: notification1, nano_material_ids: [nano_material2.id]) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when ok" do
      let(:form) { described_class.new(notification: notification1, nano_material_ids: [nano_material1.id]) }

      before do
        form
      end

      it "removes the nano_material" do
        expect { form.delete }.to change(NanoMaterial, :count).from(1).to(0)
      end

      it "returns true" do
        expect(form.delete).to be_truthy
      end
    end

    context "when notification is completed" do
      let(:notification1) { create(:registered_notification) }

      let(:form) { described_class.new(notification: notification1, nano_material_ids: [nano_material1.id]) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when notification is deleted" do
      let(:notification1) { create(:notification, :deleted) }

      let(:form) { described_class.new(notification: notification1, nano_material_ids: [nano_material1.id]) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
