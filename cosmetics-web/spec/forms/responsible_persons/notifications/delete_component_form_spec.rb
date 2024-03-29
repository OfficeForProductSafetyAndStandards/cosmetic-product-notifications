require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::DeleteComponentForm do
  let(:notification1) { create(:notification) }
  let(:component1) { create(:component, notification: notification1) }
  let(:component1_2) { create(:component, notification: notification1) }
  let(:component1_3) { create(:component, notification: notification1) }

  let(:notification2) { create(:notification) }
  let(:component2) { create(:component, notification: notification2) }

  describe "validation" do
    it "is invalid without component_id attribute present" do
      expect(described_class.new).not_to be_valid
    end
  end

  describe "#delete" do
    before do
      component1
      component1_2
      component1_3
    end

    context "when form is invalid" do
      let(:form) { described_class.new(notification: notification1) }

      it "returns false if form is invalid" do
        expect(form.delete).to eq false
      end
    end

    context "when component can not be found" do
      let(:non_existent_id) { Component.pluck(:id).max + 1 }
      let(:form) { described_class.new(notification: notification1, component_id: non_existent_id) }

      it "raises ActiveRecord::ElementNotFound" do
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

      it "removes the component" do
        expect {
          form.delete
        }.to change(Component, :count).from(3).to(2)
      end

      it "returns true" do
        expect(form.delete).to be_truthy
      end
    end

    context "when notification is completed" do
      let(:notification1) { create(:registered_notification) }

      let(:form) { described_class.new(notification: notification1, component_id: component1.id) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when notification is deleted" do
      let(:notification1) { create(:notification, :deleted) }

      let(:form) { described_class.new(notification: notification1, component_id: component1.id) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context "when notification has only 2 components" do
    let(:form) { described_class.new(notification: notification1, component_id: component1.id) }

    before do
      component1_2
      form
    end

    it "raises ActiveRecord::ElementNotFound" do
      expect { form.delete }.to raise_error(RuntimeError)
    end

    # rubocop:disable RSpec/ExampleLength
    it "does not remove the component" do
      expect {
        begin
          form.delete
        rescue StandardError
          StandardError
        end
      }.not_to change(Component, :count)
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
