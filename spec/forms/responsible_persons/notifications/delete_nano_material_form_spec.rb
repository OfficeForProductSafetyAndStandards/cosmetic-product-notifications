require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::DeleteNanoMaterialForm do
  let(:notification_a) { create(:notification) }
  let(:nano_material_a) { create(:nano_material, notification: notification_a) }

  let(:notification_b) { create(:notification) }
  let(:nano_material_b) { create(:nano_material, notification: notification_b) }

  describe "validation" do
    context "when nano_material_ids attribute is missing" do
      it "is invalid" do
        expect(described_class.new).not_to be_valid
      end
    end

    context "when nano_material_ids attribute is blank" do
      let(:form) { described_class.new(notification: notification_a, nano_material_ids: []) }

      it "is invalid" do
        expect(form).not_to be_valid
      end
    end

    context "when nano_material_ids attribute has blank elements" do
      let(:form) { described_class.new(notification: notification_a, nano_material_ids: [""]) }

      it "is invalid" do
        expect(form).not_to be_valid
      end
    end
  end

  describe "#delete" do
    context "when form is invalid" do
      let(:form) { described_class.new(notification: notification_a) }

      it "returns false if form is invalid" do
        expect(form.delete).to be false
      end
    end

    context "when nano_material can not be found" do
      let(:form) { described_class.new(notification: notification_a, nano_material_ids: [1]) }

      it "raises ActiveRecord::ElementNotFound" do
        expect(NanoMaterial.count).to eq 0 # to make sure no nano_materials are present

        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when nano_material does not belong to notification" do
      let(:form) { described_class.new(notification: notification_a, nano_material_ids: [nano_material_b.id]) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when ok" do
      let(:form) { described_class.new(notification: notification_a, nano_material_ids: [nano_material_a.id]) }

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
      let(:notification_a) { create(:registered_notification) }

      let(:form) { described_class.new(notification: notification_a, nano_material_ids: [nano_material_a.id]) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when notification is deleted" do
      let(:notification_a) { create(:notification, :deleted) }

      let(:form) { described_class.new(notification: notification_a, nano_material_ids: [nano_material_a.id]) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
