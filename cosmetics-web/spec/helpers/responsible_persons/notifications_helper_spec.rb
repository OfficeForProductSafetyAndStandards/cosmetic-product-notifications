require "rails_helper"

describe ResponsiblePersons::NotificationsHelper do
  let(:helper_class) do
    Class.new do
      include ResponsiblePersons::NotificationsHelper
      include ActionView::Helpers::RenderingHelper # Allows calling "#render"
      include ActionView::Helpers::UrlHelper       # Allows calling "#link_to"
      include ApplicationController::HelperMethods # Allows calling "#current_user"
      include Rails.application.routes.url_helpers
      include DateHelper
      include ShadesHelper
    end
  end

  let(:helper) { helper_class.new }

  describe "#notification_summary_label_image_link" do
    subject(:label_image_link) do
      helper.notification_summary_label_image_link(image, notification.responsible_person, notification)
    end

    let(:notification) { build_stubbed(:notification) }
    let(:image) { build_stubbed(:image_upload, filename: "Label image") }

    before do
      allow(helper).to receive(:url_for).and_return("/url/for/image")
    end

    it "returns a link to the image if has pased the antivirus check" do
      allow(image).to receive(:passed_antivirus_check?).and_return(true)
      allow(helper).to receive(:link_to).and_return("<a href='/url/for/image'>Label image</a>")
      expect(label_image_link).to eq("<a href='/url/for/image'>Label image</a>")
      expect(helper).to have_received(:link_to).with("Label image", "/url/for/image", class: "govuk-link govuk-link--no-visited-state")
    end

    it "returns a processing message with a refresh link if image is waiting for antivirus check" do
      allow(image).to receive_messages(passed_antivirus_check?: false, file_exists?: true)
      allow(helper).to receive_messages(link_to: "<a href='/edit/path'>Refresh</a>",
                                        edit_responsible_person_notification_path: "/edit/path")
      expect(label_image_link).to eq("Processing image testImage.png...<br><a href='/edit/path'>Refresh</a>")
      expect(helper).to have_received(:link_to).with("Refresh", "/edit/path", class: "govuk-link govuk-link--no-visited-state")
    end

    it "returns nil when the image file does not exist" do
      allow(image).to receive_messages(passed_antivirus_check?: false, file_exists?: false)
      expect(label_image_link).to eq(nil)
    end
  end

  describe "#notification_summary_references_rows" do
    subject(:summary_references_rows) { helper.notification_summary_references_rows(notification) }

    let(:notification) do
      build_stubbed(:notification,
                    :registered,
                    reference_number: "60162968",
                    cpnp_reference: "3796528",
                    cpnp_notification_date: Time.zone.parse("2019-10-04T17:10Z"),
                    notification_complete_at: Time.zone.parse("2021-05-03T12:08Z"))
    end

    it "contains rows for reference number, CPNP reference, CPNP notification date and the completion date" do
      expect(summary_references_rows).to eq([
        { key: { html: "<abbr>UK</abbr> cosmetic product number" }, value: { text: "UKCP-60162968" } },
        { key: { html: "<abbr>EU</abbr> reference number" }, value: { text: "3796528" } },
        { key: { html: "First notified in the <abbr>EU</abbr>" }, value: { text: "4 October 2019" } },
        { key: { html: "<abbr>UK</abbr> notified" }, value: { text: "3 May 2021" } },
      ])
    end

    it "does not include a row for CPNP reference if it is not present" do
      notification.cpnp_reference = nil
      expect(summary_references_rows).to eq([
        { key: { html: "<abbr>UK</abbr> cosmetic product number" }, value: { text: "UKCP-60162968" } },
        { key: { html: "First notified in the <abbr>EU</abbr>" }, value: { text: "4 October 2019" } },
        { key: { html: "<abbr>UK</abbr> notified" }, value: { text: "3 May 2021" } },
      ])
    end

    it "does not include a row for CPNP notification date if it is not present" do
      notification.cpnp_notification_date = nil
      expect(summary_references_rows).to eq([
        { key: { html: "<abbr>UK</abbr> cosmetic product number" }, value: { text: "UKCP-60162968" } },
        { key: { html: "<abbr>EU</abbr> reference number" }, value: { text: "3796528" } },
        { key: { html: "<abbr>UK</abbr> notified" }, value: { text: "3 May 2021" } },
      ])
    end

    it "does not include a row for notification completion date if it is not present" do
      notification.notification_complete_at = nil
      expect(summary_references_rows).to eq([
        { key: { html: "<abbr>UK</abbr> cosmetic product number" }, value: { text: "UKCP-60162968" } },
        { key: { html: "<abbr>EU</abbr> reference number" }, value: { text: "3796528" } },
        { key: { html: "First notified in the <abbr>EU</abbr>" }, value: { text: "4 October 2019" } },
      ])
    end
  end

  describe "#notification_summary_product_rows" do
    subject(:summary_product_rows) do
      helper.notification_summary_product_rows(notification, allow_edits: allow_edits)
    end

    let(:helper) { helper_class.new }
    let(:allow_edits) { false }
    let(:notification) do
      build_stubbed(:notification,
                    :registered,
                    reference_number: "60162968",
                    product_name: "Product Test",
                    industry_reference: "CPNP-3874065",
                    cpnp_reference: "3796528",
                    cpnp_notification_date: Time.zone.parse("2019-10-04T17:10Z"),
                    notification_complete_at: Time.zone.parse("2021-05-03T12:08Z"))
    end
    let(:user) { build_stubbed(:submit_user) }

    before do
      allow(helper).to receive_messages(render: "", current_user: user)
    end

    it "contains the product name" do
      expect(summary_product_rows).to include({ key: { text: "Product name" }, value: { text: "Product Test" } })
    end

    it "contains the industry reference number" do
      expect(summary_product_rows).to include({ key: { text: "Internal reference number" }, value: { text: "CPNP-3874065" } })
    end

    it "contains the number of components associated with the notification" do
      expect(summary_product_rows).to include({ key: { text: "Number of items" }, value: { text: 0 } })
    end

    it "contains notification shades html" do
      allow(helper).to receive(:display_shades).and_return("Shades info")
      expect(summary_product_rows).to include({ key: { text: "Shades" }, value: { html: "Shades info" } })
    end

    it "contains info indicating when the notification components are mixed" do
      notification.components_are_mixed = true
      expect(summary_product_rows).to include({ key: { text: "Are the items mixed?" }, value: { text: "Yes" } })
    end

    it "contains info indicating when the notification components are not mixed" do
      notification.components_are_mixed = false
      expect(summary_product_rows).to include({ key: { text: "Are the items mixed?" }, value: { text: "No" } })
    end

    describe "label image" do
      before do
        allow(helper).to receive(:render)
          .with("notifications/product_details_label_images", notification: notification, allow_edits: allow_edits)
          .and_return("Label image html")
      end

      context "when edits are not allowed" do
        let(:allow_edits) { false }

        it "contains the label image html without any actions" do
          expect(summary_product_rows).to include(
            { key: { text: "Label image" }, value: { html: "Label image html" }, actions: { items: [] } },
          )
        end
      end

      context "when edits are  allowed" do
        let(:allow_edits) { true }

        it "contains the label image html without any actions for notifications without images" do
          allow(notification).to receive(:image_uploads).and_return([])
          expect(summary_product_rows).to include(
            { key: { text: "Label image" }, value: { html: "Label image html" }, actions: { items: [] } },
          )
        end

        # rubocop:disable RSpec/ExampleLength
        it "contains the label image html with Change action for notifications with images" do
          allow(notification).to receive(:image_uploads).and_return(build_stubbed_list(:image_upload, 1))
          allow(helper).to receive(:edit_responsible_person_notification_product_images_path).and_return("/product/image/edit/path")
          expect(summary_product_rows).to include(
            { key: { text: "Label image" },
              value: { html: "Label image html" },
              actions: { items: [{ href: "/product/image/edit/path",
                                   text: "Change",
                                   visuallyHiddenText: "label image",
                                   classes: "govuk-link--no-visited-state" }] } },
          )
        end
        # rubocop:enable RSpec/ExampleLength
      end
    end

    describe "for children under 3" do
      it "not included when not available for the notification" do
        notification.under_three_years = nil
        expect(summary_product_rows).not_to include(hash_including(key: { text: "For children under 3" }))
      end

      it "included when notification product is for children under 3" do
        notification.under_three_years = true
        expect(summary_product_rows).to include({ key: { text: "For children under 3" }, value: { text: "Yes" } })
      end

      it "included when notification product is not for children under 3" do
        notification.under_three_years = false
        expect(summary_product_rows).to include({ key: { text: "For children under 3" }, value: { text: "No" } })
      end
    end

    describe "PH information" do
      context "when current user can view the product ingredients" do
        before { allow(user).to receive(:can_view_product_ingredients?).and_return(true) }

        it "contains the product PH minimum value when present" do
          notification.ph_min_value = 0.3
          expect(summary_product_rows).to include(
            { key: { html: "Minimum <abbr title='Power of hydrogen'>pH</abbr> value" }, value: { text: 0.3 } },
          )
        end

        it "does not contain the product PH minimum value when not present" do
          notification.ph_min_value = nil
          expect(summary_product_rows).not_to include(
            hash_including(key: { html: "Minimum <abbr title='Power of hydrogen'>pH</abbr> value" }),
          )
        end

        it "contains the product PH maximum value when present" do
          notification.ph_max_value = 0.7
          expect(summary_product_rows).to include(
            { key: { html: "Maximum <abbr title='Power of hydrogen'>pH</abbr> value" }, value: { text: 0.7 } },
          )
        end

        it "does not contain the product PH maximum value when not present" do
          notification.ph_max_value = nil
          expect(summary_product_rows).not_to include(
            hash_including(key: { html: "Maximum <abbr title='Power of hydrogen'>pH</abbr> value" }),
          )
        end
      end

      context "when the current user cannot view the product ingredients" do
        before { allow(user).to receive(:can_view_product_ingredients?).and_return(false) }

        it "does not contain the product PH minimum value even when is available" do
          notification.ph_min_value = 0.3
          expect(summary_product_rows).not_to include(
            hash_including(key: { html: "Minimum <abbr title='Power of hydrogen'>pH</abbr> value" }),
          )
        end

        it "does not contain the product PH minimum value when not available" do
          notification.ph_min_value = nil
          expect(summary_product_rows).not_to include(
            hash_including(key: { html: "Minimum <abbr title='Power of hydrogen'>pH</abbr> value" }),
          )
        end

        it "does not contain the product PH maximum value even when is available" do
          notification.ph_max_value = 0.7
          expect(summary_product_rows).not_to include(
            hash_including(key: { html: "Maximum <abbr title='Power of hydrogen'>pH</abbr> value" }),
          )
        end

        it "does not contain the product PH maximum value when not available" do
          notification.ph_max_value = nil
          expect(summary_product_rows).not_to include(
            hash_including(key: { html: "Maximum <abbr title='Power of hydrogen'>pH</abbr> value" }),
          )
        end
      end
    end
  end
end
