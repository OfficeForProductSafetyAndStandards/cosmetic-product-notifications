require "rails_helper"

RSpec.describe DraftHelper, type: :helper do
  let!(:notification) { create(:notification, state: Notification::READY_FOR_COMPONENTS) }
  let(:component) { create(:component, name: "Component X", notification:) }

  describe "#component_badge" do
    subject(:component_badge_html) { helper.component_badge(component, 1) }

    context "when section cannot be used" do
      before { allow(helper).to receive(:section_can_be_used?).with(DraftHelper::ITEMS_SECTION).and_return(false) }

      it "displays 'Cannot start yet' badge" do
        expect(component_badge_html).to include("cannot start yet")
      end

      it "displays the component name" do
        expect(component_badge_html).to include("Component x")
      end
    end

    context "when section can be used" do
      before { allow(helper).to receive(:section_can_be_used?).with(DraftHelper::ITEMS_SECTION).and_return(true) }

      context "when notification state is 'product_name_added'" do
        before { allow(notification).to receive(:state).and_return("product_name_added") }

        it "displays 'Cannot start yet' badge" do
          expect(component_badge_html).to include("cannot start yet")
        end
      end

      context "when component is empty" do
        before { allow(component).to receive(:empty?).and_return(true) }

        it "displays 'Not started' badge" do
          expect(component_badge_html).to include("not started")
        end
      end

      context "when component is completed" do
        before do
          allow(component).to receive(:empty?).and_return(false)
          allow(component).to receive(:component_complete?).and_return(true)
        end

        it "displays 'Complete' badge" do
          expect(component_badge_html).to include("complete")
        end
      end
    end
  end
end
