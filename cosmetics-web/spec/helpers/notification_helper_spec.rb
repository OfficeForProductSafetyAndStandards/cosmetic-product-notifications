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

  describe "#component_nano_materials_names" do
    it "returns the component nano materials names" do
      nano_material1 = build(:nano_material, inci_name: "Nano material 1")
      nano_material2 = build(:nano_material, inci_name: "Nano material 2")
      component = build(:component, nano_materials: [nano_material1, nano_material2])

      expect(helper.component_nano_materials_names(component)).to eq(["Nano material 1", "Nano material 2"])
    end
  end

  describe "#nano_materials_with_pdf_links" do
    context "with standard nanomaterials" do
      it "returns the component nano materials names" do
        nano_materials = [build_stubbed(:nano_material, inci_name: "Nano material 1"),
                          build_stubbed(:nano_material, inci_name: "Nano material 2")]

        expect(helper.nano_materials_with_pdf_links(nano_materials)).to eq(["Nano material 1", "Nano material 2"])
      end
    end

    context "with non standard nanomaterials associated with a nanomaterial notification do" do
      let(:nanomaterial_notification) { build_stubbed(:nanomaterial_notification, :submitted, name: "Nano 1", id: 1) }
      let(:nano_materials) { [build_stubbed(:nano_material, nanomaterial_notification:)] }

      context "when there is a file link returned for the nanomaterial notification" do
        before do
          allow(helper).to receive(:nanomaterial_notification_file_link).and_return("<a href='/url/for/pdf'>Nano PDF</a>")
        end

        it "returns the nano materials notifications UKN, name and link to their PDF" do
          expect(helper.nano_materials_with_pdf_links(nano_materials))
            .to eq(["UKN-1 - Nano 1 </br> <a href='/url/for/pdf'>Nano PDF</a>"])
        end
      end

      context "when there is no file link returned for the nanomaterial notification" do
        before do
          allow(helper).to receive(:nanomaterial_notification_file_link).and_return(nil)
        end

        it "returns the nano materials notifications UKN and name" do
          expect(helper.nano_materials_with_pdf_links(nano_materials))
            .to eq(["UKN-1 - Nano 1"])
        end
      end
    end
  end

  describe "#nanomaterial_notification_file_link" do
    let(:stubbed_file) { instance_double(ActiveStorage::Blob, filename: "Nano.pdf") }
    let(:nanomaterial_notification) { instance_double(NanomaterialNotification, file: stubbed_file) }

    before do
      allow(helper).to receive(:link_to).and_return("<a href='/url/for/pdf'>Nano.pdf</a>")
    end

    it "returns nil when no nanomaterial notification is given" do
      expect(helper.nanomaterial_notification_file_link(nil)).to be_nil
    end

    it "returns nil when the nano notification file haven't passed the antivirus check" do
      allow(nanomaterial_notification).to receive(:passed_antivirus_check?).and_return(false)
      expect(helper.nanomaterial_notification_file_link(nanomaterial_notification)).to be_nil
    end

    it "returns the link to the file when the nano notification file have passed the antivirus check" do
      allow(nanomaterial_notification).to receive(:passed_antivirus_check?).and_return(true)
      allow(helper).to receive(:url_for).with(stubbed_file).and_return("/url/for/pdf")
      allow(helper).to receive(:link_to).and_return("<a href='/url/for/pdf'>Nano.pdf</a>")

      expect(helper.nanomaterial_notification_file_link(nanomaterial_notification))
        .to eq("<a href='/url/for/pdf'>Nano.pdf</a>")
      expect(helper).to have_received(:link_to).with("Nano.pdf", "/url/for/pdf", anything)
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
