require "rails_helper"

describe NotificationHelper do
  let(:helper_class) do
    Class.new do
      include ApplicationHelper
      include ActionView::Helpers
      include ApplicationController::HelperMethods
      include Rails.application.routes.url_helpers
    end
  end

  let(:helper) { helper_class.new }

  describe "#nano_materials_details" do
    context "with standard nanomaterials" do
      it "returns the component nano materials names" do
        nano_materials = [build_stubbed(:nano_material, inci_name: "Nano material 1"),
                          build_stubbed(:nano_material, inci_name: "Nano material 2")]

        expect(helper.nano_materials_details(nano_materials)).to eq(["Nano material 1", "Nano material 2"])
      end
    end

    context "with non standard nanomaterials associated with a nanomaterial notification do" do
      let(:nanomaterial_notification) { build_stubbed(:nanomaterial_notification, :submitted, name: "Nano 1", id: 1) }
      let(:nano_materials) { [build_stubbed(:nano_material, nanomaterial_notification:)] }

      before do
        allow(helper).to receive(:render)
                     .with("notifications/nanomaterial_notification_details", nanomaterial_notification:)
                     .and_return(rendered_details)
      end

      context "when there are file details rendered for the nanomaterial notification" do
        let(:rendered_details) { "UKN-1 - Nano1 </br> <a href='/url/for/pdf'>Nano PDF</a> <span>PDF, 12 KB</span>" }

        it "returns the nano materials notifications UKN, link to their PDF and PDF info" do
          expect(helper.nano_materials_details(nano_materials)).to eq([rendered_details])
        end
      end

      context "when there is no file details rendered for the nanomaterial notification" do
        let(:rendered_details) { "UKN-1 - Nano1" }

        it "returns the nano materials notifications UKN and name" do
          expect(helper.nano_materials_details(nano_materials)).to eq([rendered_details])
        end
      end
    end
  end

  describe "#nano_materials_with_review_period_end_date" do
    let(:notification1) do
      instance_double(NanomaterialNotification,
                      ukn: "UKN-1",
                      name: "Nano material 1",
                      can_be_made_available_on_uk_market_from: Date.new(2022, 1, 1))
    end

    let(:notification2) do
      instance_double(NanomaterialNotification,
                      ukn: "UKN-2",
                      name: "Nano material 2",
                      can_be_made_available_on_uk_market_from: Date.new(2022, 2, 10))
    end

    it "returns formated UKN, name and the end where the review period ends for the associated nanomaterial notifications" do
      nano_material1 = instance_double(NanoMaterial, nanomaterial_notification: notification1)
      nano_material2 = instance_double(NanoMaterial, nanomaterial_notification: notification2)
      expect(helper.nano_materials_with_review_period_end_date([nano_material1, nano_material2]))
        .to eq(["UKN-1 - Nano material 1 - 1 January 2022",
                "UKN-2 - Nano material 2 - 10 February 2022"])
    end

    it "ignoresnanomaterials without an associated nanomaterial notification" do
      nano_material1 = instance_double(NanoMaterial, nanomaterial_notification: nil)
      nano_material2 = instance_double(NanoMaterial, nanomaterial_notification: notification2)
      expect(helper.nano_materials_with_review_period_end_date([nano_material1, nano_material2]))
        .to eq(["UKN-2 - Nano material 2 - 10 February 2022"])
    end
  end
end
