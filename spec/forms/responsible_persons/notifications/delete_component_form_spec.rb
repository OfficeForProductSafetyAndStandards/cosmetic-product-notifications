require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::DeleteComponentForm do
  let(:notification_a) { create(:notification) }
  let(:component_a) { create(:component, notification: notification_a) }
  let(:component_b) { create(:component, notification: notification_a) }
  let(:component_c) { create(:component, notification: notification_a) }

  let(:notification_b) { create(:notification) }
  let(:component_d) { create(:component, notification: notification_b) }

  describe "validation" do
    it "is invalid without component_id attribute present" do
      expect(described_class.new).not_to be_valid
    end
  end

  describe "#delete" do
    before do
      component_a
      component_b
      component_c
    end

    context "when form is invalid" do
      let(:form) { described_class.new(notification: notification_a) }

      it "returns false if form is invalid" do
        expect(form.delete).to be false
      end
    end

    context "when component can not be found" do
      let(:non_existent_id) { Component.pluck(:id).max + 1 }
      let(:form) { described_class.new(notification: notification_a, component_id: non_existent_id) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when component does not belong to notification" do
      let(:form) { described_class.new(notification: notification_a, component_id: component_d.id) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when ok" do
      let(:form) { described_class.new(notification: notification_a, component_id: component_a.id) }

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
      let(:notification_a) { create(:registered_notification) }

      let(:form) { described_class.new(notification: notification_a, component_id: component_a.id) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when notification is deleted" do
      let(:notification_a) { create(:notification, :deleted) }

      let(:form) { described_class.new(notification: notification_a, component_id: component_a.id) }

      it "raises ActiveRecord::ElementNotFound" do
        expect { form.delete }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context "when notification has only 2 components" do
    let(:form) { described_class.new(notification: notification_a, component_id: component_a.id) }

    before do
      component_b
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
