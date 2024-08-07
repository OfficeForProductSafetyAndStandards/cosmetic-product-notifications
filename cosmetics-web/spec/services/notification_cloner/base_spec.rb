require "rails_helper"

RSpec.describe NotificationCloner::Base do
  let(:notification) { create(:registered_notification) }
  let(:product_name) { "Cloned notification" }
  let(:new_notification_with_name_only) { Notification.create!(product_name:, responsible_person: notification.responsible_person) }

  let(:nanomaterial_a) { create(:nano_material, notification:) }
  let(:nanomaterial_b) { create(:nano_material_non_standard, :toxicology_notified, notification:) }

  let(:component1) { create(:ranges_component, :completed, :with_range_ingredients, notification:) }

  before do
    create(:exact_component, :completed, :with_exact_ingredient, notification:)
    create(:cmr, component: component1)

    component1.nano_materials << nanomaterial_a
    component1.nano_materials << nanomaterial_b
  end

  describe "Notification cloning" do
    context "when notification has components, nanomaterials and ingredients" do
      let!(:new_notification) { described_class.clone(notification, new_notification_with_name_only) }

      it "clones notification" do
        expect(new_notification.id).not_to eq(notification.id)
        expect(new_notification.source_notification).to eq(notification)
      end

      it "clones notification component" do
        expect(new_notification.components.map(&:id)).not_to eq(notification.components.map(&:id))
      end

      it "does not changes name" do
        expect(new_notification.product_name).to eq(product_name)
      end

      it "clones notification nanomaterials" do
        expect(new_notification.nano_materials.map(&:id)).not_to eq(notification.nano_materials.map(&:id))
      end

      it "does not set cloned nanomaterials in complete state" do
        expect(new_notification.nano_materials.map(&:completed?).uniq).to eq([false])
      end

      it "clones some notification attributes" do
        new_attributes = new_notification.attributes.slice(Notification::CLONABLE_ATTRIBUTES)
        old_attributes = notification.attributes.slice(Notification::CLONABLE_ATTRIBUTES)

        expect(new_attributes).to eq(old_attributes)
      end

      it "clones some components attributes" do
        new_attributes = new_notification.components.map { |c| c.attributes.slice(Component::CLONABLE_ATTRIBUTES) }
        old_attributes = notification.components.map { |c| c.attributes.slice(Component::CLONABLE_ATTRIBUTES) }

        expect(new_attributes).to eq(old_attributes)
      end

      it "clones some nano_materials attributes" do
        new_attributes = new_notification.nano_materials.map { |c| c.attributes.slice(NanoMaterial::CLONABLE_ATTRIBUTES) }
        old_attributes = notification.nano_materials.map { |c| c.attributes.slice(NanoMaterial::CLONABLE_ATTRIBUTES) }

        expect(new_attributes).to eq(old_attributes)
      end

      it "sets proper state for notification" do
        expect(new_notification.state).to eq(NotificationStateConcern::PRODUCT_NAME_ADDED.to_s)
      end

      it "sets proper state for components" do
        expect(new_notification.components.map(&:state)).to eq(%w[empty empty])
      end

      it "creates component and nano material association properly" do
        old_attributes = notification.components.map do |c|
          c.nano_materials.map { |n| n.slice(NanoMaterial::CLONABLE_ATTRIBUTES) }
        end

        new_attributes = new_notification.components.map do |c|
          c.nano_materials.map { |n| n.slice(NanoMaterial::CLONABLE_ATTRIBUTES) }
        end

        expect(new_attributes).to eq(old_attributes)
      end

      it "keeps track of parent notification" do
        expect(new_notification.reload.source_notification).to eq(notification)
      end
    end
  end
end
