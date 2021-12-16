require "rails_helper"

RSpec.describe NotificationWizard::DeleteComponentForm do
  let(:notification1) { create(:notification) }
  let(:component1) {create(:component, notification: notification1) }

  let(:notification2) { create(:notification) }
  let(:component2) {create(:component, notification: notification2) }


  describe "validation" do
    it "should be invalid without component_id attribute present" do
      expect(described_class.new.valid?).to be_falsey
    end
  end

  describe "#delete" do
    context "when form is invalid" do
      let(:form) { described_class.new(notification: notification1) }

      it "returns false if form is invalid" do
        expect(form.delete).to eq false
      end
    end

    context "if component can not be found" do
      let(:form) { described_class.new(notification: notification1, component_id: 1) }

      it "raises ActiveRecord::ElementNotFound" do
        expect(Component.count).to eq 0 # to make sure no components are present

        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when component does not belong to notification" do
      let(:form) { described_class.new(notification: notification1, component_id: component2.id) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when ok" do
      let(:form) { described_class.new(notification: notification1, component_id: component1.id) }

      before do
        form
      end

      it "removes the component" do
        expect do
          form.delete
        end.to change { Component.count }.from(1).to(0)
      end

      it "returns true" do
        expect(form.delete).to be_truthy
      end
    end
  end
end
