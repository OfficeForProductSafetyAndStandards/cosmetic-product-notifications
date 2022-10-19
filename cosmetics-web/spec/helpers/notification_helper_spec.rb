require "rails_helper"

describe NotificationHelper do
  let(:helper_class) do
    Class.new do
      include ApplicationController::HelperMethods
    end
  end

  let(:helper) { helper_class.new }

  describe "#component_nano_materials_names" do
    it "returns the component nano materials names" do
      nano_material1 = build(:nano_material, inci_name: "Nano material 1")
      nano_material2 = build(:nano_material, inci_name: "Nano material 2")
      component = build(:component, nano_materials: [nano_material1, nano_material2])

      expect(helper.component_nano_materials_names(component)).to eq(["Nano material 1", "Nano material 2"])
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
