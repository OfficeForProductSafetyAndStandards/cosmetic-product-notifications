require "rails_helper"

RSpec.describe NotificationSearchResultDecorator do
  let(:notification) { create(:notification) }
  let(:decorator) { described_class.new(notification) }

  describe "#are_these_items_mixed" do
    context "when notification has no components" do
      it "returns 'No'" do
        expect(decorator.are_these_items_mixed).to eq "No"
      end
    end

    context "when notification has one component" do
      let(:notification) { create(:notification, :with_component) }

      it "returns 'No'" do
        expect(decorator.are_these_items_mixed).to eq "No"
      end
    end

    context "when notification is multi component" do
      context "and components_are_mixed is true" do
        let(:notification) { create(:notification, :with_components, components_are_mixed: true) }

        it "returns 'Yes'" do
          expect(decorator.are_these_items_mixed).to eq "Yes"
        end
      end

      context "and components_are_mixed is false" do
        let(:notification) { create(:notification, :with_components, components_are_mixed: false) }

        it "returns 'No'" do
          expect(decorator.are_these_items_mixed).to eq "No"
        end
      end
    end
  end
end
