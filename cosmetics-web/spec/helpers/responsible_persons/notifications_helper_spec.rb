require "rails_helper"

describe ResponsiblePersons::NotificationsHelper do
  let(:helper_class) do
    Class.new do
      include ApplicationHelper
      include ActionView::Helpers
      include ApplicationController::HelperMethods # Allows calling "#current_user"
      include Rails.application.routes.url_helpers
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
    let(:user) { instance_double(SubmitUser, can_view_product_ingredients?: true) }

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

      context "when edits are allowed" do
        let(:allow_edits) { true }

        it "contains the label image html without any actions for notifications without images" do
          allow(notification).to receive(:image_uploads).and_return([])
          expect(summary_product_rows).to include(
            { key: { text: "Label image" }, value: { html: "Label image html" }, actions: { items: [] } },
          )
        end

        # rubocop:disable RSpec/ExampleLength
        it "contains the label image html with Change action for notifications with images" do
          allow(notification).to receive(:image_uploads).and_return([instance_double(ImageUpload)])
          allow(helper).to receive(:responsible_person_notification_product_path).and_return("/product/image/edit/path")
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

  describe "#notification_summary_component_rows" do
    subject(:summary_component_rows) do
      helper.notification_summary_component_rows(component, include_shades: include_shades, allow_edits: allow_edits)
    end

    let(:include_shades) { false }
    let(:allow_edits) { false }
    let(:component) do
      build_stubbed(:component,
                    exposure_routes: %w[Route],
                    exposure_condition: "rinse_off")
    end
    let(:user) { instance_double(SubmitUser, can_view_product_ingredients?: true) }

    before do
      allow(helper).to receive_messages(current_user: user, render: "")
    end

    context "when including shades flag is set to false" do
      it "does not contain the component shades html" do
        expect(summary_component_rows).not_to include(hash_including({ key: { text: "Shades" } }))
      end
    end

    context "when including shades flag is set to true" do
      let(:include_shades) { true }

      it "includes the shades html" do
        component.shades = %w[blue brown]
        allow(helper).to receive(:render).and_return("Shades html")
        expect(summary_component_rows).to include(hash_including({ key: { text: "Shades" }, value: { html: "Shades html" } }))
        expect(helper).to have_received(:render).with("none_or_bullet_list", hash_including(entities_list: %w[blue brown]))
      end
    end

    context "when containing CMR substances" do
      let(:cmr) { instance_double(Cmr, display_name: "Test CMR,123456,654321") }

      before do
        allow(component).to receive(:cmrs).and_return([cmr])
      end

      it "includes the confirmation of containing CMR substances" do
        expect(summary_component_rows).to include(
          { key: { html: "Contains <abbr title='Carcinogenic, mutagenic, reprotoxic'>CMR</abbr> substances" },
            value: { text: "Yes" } },
        )
      end

      it "includes the CMR substance names" do
        allow(helper).to receive(:render).and_return("CMR html")
        expect(summary_component_rows).to include({ key: { html: "<abbr title='Carcinogenic, mutagenic, reprotoxic'>CMR</abbr> substances" },
                                                    value: { html: "CMR html" } })
        expect(helper).to have_received(:render).with("application/none_or_bullet_list",
                                                      hash_including(entities_list: ["Test CMR,123456,654321"]))
      end
    end

    describe "nanomaterials" do
      context "when there aren't any nano elements present" do
        it "contains a row indication that there are no nanomaterials" do
          allow(helper).to receive(:render).and_return("None")
          expect(summary_component_rows).to include({ key: { text: "Nanomaterials" }, value: { html: "None" } })
          expect(helper).to have_received(:render).with("application/none_or_bullet_list", hash_including(entities_list: []))
        end

        it "does not contains a row with the nano material application exposure instruction" do
          expect(summary_component_rows).not_to include(hash_including({ key: { text: "Application instruction" } }))
        end

        it "does not contains a row with the nano material application exposure condition" do
          expect(summary_component_rows).not_to include(hash_including({ key: { text: "Exposure condition" } }))
        end
      end

      context "when there are nano elements present" do
        let(:nano_material) do
          instance_double(NanoMaterial,
                          nano_elements: [instance_double(NanoElement, display_name: "NanoEl name")])
        end

        before do
          allow(component).to receive(:nano_materials).and_return([nano_material])
        end

        it "contains a row with the nano element names" do
          allow(helper).to receive(:render).and_return("NanoEl name")
          expect(summary_component_rows).to include({ key: { text: "Nanomaterials" }, value: { html: "NanoEl name" } })
          expect(helper).to have_received(:render).with("application/none_or_bullet_list", hash_including(entities_list: ["NanoEl name"]))
        end

        it "contains a row with the nano material application instruction" do
          allow(helper).to receive(:get_exposure_routes_names).with(%w[Route]).and_return("Route name")
          expect(summary_component_rows).to include({ key: { text: "Application instruction" }, value: { text: "Route name" } })
        end

        it "contains a row with the nano material application exposure condition" do
          allow(helper).to receive(:get_exposure_condition_name).with("rinse_off").and_return("Condition name")
          expect(summary_component_rows).to include({ key: { text: "Exposure condition" }, value: { text: "Condition name" } })
        end
      end
    end

    describe "component categories" do
      before do
        allow(component).to receive_messages(
          root_category: "Category",
          sub_category: "SubCategory",
          sub_sub_category: "SubSubCategory",
        )
        allow(helper).to receive(:get_category_name).with("Category").and_return("Category name")
        allow(helper).to receive(:get_category_name).with("SubCategory").and_return("SubCategory name")
        allow(helper).to receive(:get_category_name).with("SubSubCategory").and_return("SubSubCategory name")
      end

      it "contains a row with the component category" do
        expect(summary_component_rows).to include({ key: { text: "Category of product" }, value: { text: "Category name" } })
      end

      it "contains a row with the component subcategory" do
        expect(summary_component_rows).to include({ key: { text: "Category of category name" }, value: { text: "SubCategory name" } })
      end

      it "contains a row with the component subsubcategory" do
        expect(summary_component_rows).to include({ key: { text: "Category of subcategory name" }, value: { text: "SubSubCategory name" } })
      end
    end

    context "when user can view product ingredients" do
      before do
        allow(user).to receive(:can_view_product_ingredients?).and_return(true)
      end

      it "includes the component notification type" do
        allow(helper).to receive(:get_notification_type_name).and_return("Notification type name")
        expect(summary_component_rows).to include(
          { key: { text: "Formulation given as" }, value: { text: "Notification type name" } },
        )
      end

      it "includes the frame formulation for predefined components" do
        allow(component).to receive(:predefined?).and_return(true)
        allow(helper).to receive(:get_frame_formulation_name).and_return("Frame formulation name")
        expect(summary_component_rows).to include(
          { key: { text: "Frame formulation" }, value: { text: "Frame formulation name" } },
        )
      end

      describe "non predefined documents" do
        before do
          allow(component).to receive(:predefined?).and_return(false)
          allow(helper).to receive(:render).with(
            "notifications/component_details_formulation_ingredients",
            component: component,
            allow_edits: allow_edits,
          ).and_return("Formulation html")
        end

        context "when edits are allowed" do
          let(:allow_edits) { true }

          it "includes the formulation html with formulation actions" do
            allow(helper).to receive(:componment_formulation_actions_items).and_return(%(Edit Delete))
            expect(summary_component_rows).to include(
              { key: { text: "Formulation" },
                value: { html: "Formulation html" },
                actions: { items: %(Edit Delete) } },
            )
          end
        end

        context "when edits are not allowed" do
          let(:allow_edits) { false }

          it "includes the formulation html without formulation actions" do
            allow(helper).to receive(:componment_formulation_actions_items).and_return(%(Edit Delete))
            expect(summary_component_rows).to include(
              { key: { text: "Formulation" },
                value: { html: "Formulation html" },
                actions: { items: [] } },
            )
          end
        end
      end

      it "indicates when the special applicator is used for the component" do
        allow(component).to receive(:special_applicator).and_return("Very special")
        expect(summary_component_rows).to include(
          { key: { text: "Special applicator" }, value: { text: "Yes" } },
        )
      end

      it "indicates when the special applicator is not used for the component" do
        allow(component).to receive(:special_applicator).and_return(nil)
        expect(summary_component_rows).to include(
          { key: { text: "Special applicator" }, value: { text: "No" } },
        )
      end

      it "includes the applicator type when the special application is present" do
        allow(component).to receive(:special_applicator).and_return("Very special")
        allow(helper).to receive(:component_special_applicator_name).and_return("SuperApplicator")
        expect(summary_component_rows).to include(
          { key: { text: "Applicator type" }, value: { text: "SuperApplicator" } },
        )
      end

      it "includes the acute poisoning information" do
        allow(component).to receive(:acute_poisoning_info).and_return("Poisonous")
        expect(summary_component_rows).to include(
          { key: { text: "Acute poisoning information" }, value: { text: "Poisonous" } },
        )
      end

      it "includes information about NPIS ingredients if is predefined" do
        allow(component).to receive_messages(predefined?: true,
                                             poisonous_ingredients_answer: "Yes it does")
        expect(summary_component_rows).to include(
          { key: { html: "Contains ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about" },
            value: { text: "Yes it does" } },
        )
      end

      it "does not include information about NPIS ingredients if is not predefined" do
        allow(component).to receive(:predefined?).and_return(false)
        expect(summary_component_rows).not_to include(
          hash_including(
            { key: { html: "Contains ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about" } },
          ),
        )
      end

      # rubocop:disable RSpec/ExampleLength
      it "includes the NPIS ingredients if is predefined and contains poisonous ingredients" do
        allow(component).to receive_messages(predefined?: true, contains_poisonous_ingredients: true)
        allow(helper).to receive(:render)
                     .with("notifications/component_details_poisonous_ingredients", anything)
                     .and_return("Poisonous ingredients HTML")
        expect(summary_component_rows).to include(
          { key: { html: "Ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about" },
            value: { html: "Poisonous ingredients HTML" },
            actions: { items: [] } },
        )
      end
      # rubocop:enable RSpec/ExampleLength

      it "does not include the NPIS ingredients if they're not available" do
        allow(component).to receive_messages(predefined?: true, contains_poisonous_ingredients: false)
        expect(summary_component_rows).not_to include(
          hash_including(
            { key: { html: "Ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about" } },
          ),
        )
      end
    end

    context "when user can not view product ingredients" do
      before do
        allow(user).to receive(:can_view_product_ingredients?).and_return(false)
      end

      it "does not include the component notification type" do
        expect(summary_component_rows).not_to include(hash_including({ key: { text: "Formulation given as" } }))
      end

      it "does not include the frame formulation for predefined components" do
        allow(component).to receive(:predefined?).and_return(true)
        expect(summary_component_rows).not_to include(hash_including({ key: { text: "Frame formulation" } }))
      end

      it "does not include the formulation for non predefined components" do
        allow(component).to receive(:predefined?).and_return(false)
        expect(summary_component_rows).not_to include(hash_including({ key: { text: "Formulation" } }))
      end

      it "does not indicate when the special applicator is used for the component" do
        allow(component).to receive(:special_applicator).and_return("Very special")
        expect(summary_component_rows).not_to include(hash_including({ key: { text: "Special applicator" } }))
      end

      it "does not includes the applicator type" do
        allow(component).to receive(:special_applicator).and_return("Very special")
        expect(summary_component_rows).not_to include(hash_including({ key: { text: "Applicator type" } }))
      end

      it "does not include the acute poisoning information" do
        allow(component).to receive(:acute_poisoning_info).and_return("Poisonous")
        expect(summary_component_rows).not_to include(hash_including({ key: { text: "Acute poisoning information" } }))
      end

      it "does not include information about NPIS ingredients even if is predefined" do
        allow(component).to receive(:predefined?).and_return(true)
        expect(summary_component_rows).not_to include(
          hash_including(
            { key: { html: "Contains ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about" } },
          ),
        )
      end

      it "does not include the NPIS ingredients even if they're available" do
        allow(component).to receive_messages(predefined?: true, contains_poisonous_ingredients: true)
        expect(summary_component_rows).not_to include(
          hash_including(
            { key: { html: "Ingredients <abbr title='National Poisons Information Service'>NPIS</abbr> needs to know about" } },
          ),
        )
      end
    end

    it "includes a row with the component physical form" do
      allow(helper).to receive(:get_physical_form_name).and_return("Physical form name")
      expect(summary_component_rows).to include({ key: { text: "Physical form" }, value: { text: "Physical form name" } })
    end

    describe "pH" do
      before do
        allow(component).to receive_messages(ph_range_not_required?: false)
      end

      context "when user can view product ingredients" do
        before do
          allow(user).to receive(:can_view_product_ingredients?).and_return(true)
        end

        it "includes a row with the pH selection when pH range is not required" do
          allow(component).to receive_messages(ph_range_not_required?: true, ph: :not_given)
          expect(summary_component_rows).to include({ key: { html: "<abbr title='Power of hydrogen'>pH</abbr>" },
                                                      value: { text: "Not given" } })
        end

        it "includes a row with a single pH value when minimum and maximum pH match" do
          component.minimum_ph = 0.7
          component.maximum_ph = 0.7
          expect(summary_component_rows).to include({ key: { html: "Exact <abbr title='Power of hydrogen'>pH</abbr>" },
                                                      value: { text: 0.7 } })
        end

        it "includes a row withboth pH valus when minimum and maximum pH differ" do
          component.minimum_ph = 0.7
          component.maximum_ph = 1.0
          expect(summary_component_rows).to include({ key: { html: "<abbr title='Power of hydrogen'>pH</abbr> range" },
                                                      value: { text: "0.7 to 1.0" } })
        end
      end

      it "does not include a row with the pH selection or value if user can not view ingredients" do
        allow(user).to receive(:can_view_product_ingredients?).and_return(false)
        component.minimum_ph = 0.7
        component.maximum_ph = 0.7
        expect(summary_component_rows).to not_include(
          hash_including({ key: { html: "Exact <abbr title='Power of hydrogen'>pH</abbr>" } }),
        ).and not_include(hash_including({ key: { html: "<abbr title='Power of hydrogen'>pH</abbr> range" } }))
      end
    end

    describe "trigger questions" do
      let(:element) do
        instance_double(TriggerQuestionElement, answer: "66")
      end
      let(:trigger_question) do
        instance_double(TriggerQuestion,
                        ph_question?: false,
                        question: "please_indicate_the_total_level_of_essential_oils",
                        trigger_question_elements: [element])
      end

      before do
        allow(component).to receive(:trigger_questions).and_return([trigger_question])
        allow(helper).to receive_messages(
          get_trigger_rules_short_question_name: "Indicate the total level of essential oils",
        )
      end

      it "does not include a row with the trigger question if is a ph question" do
        allow(trigger_question).to receive(:ph_question?).and_return(true)
        expect(summary_component_rows).to not_include(
          hash_including({ key: { text: "Indicate the total level of essential oils" } }),
        )
      end

      it "includes a row with element concentration for a single element given as concentration" do
        allow(element).to receive(:value_given_as_concentration?).and_return(true)
        allow(helper).to receive(:display_concentration).and_return("66% w/w")
        expect(summary_component_rows).to include(
          { key: { text: "Indicate the total level of essential oils" },
            value: { html: "66% w/w" } },
        )
      end

      it "includes a row with formatted element for a single element not given as concentration" do
        allow(element).to receive(:value_given_as_concentration?).and_return(false)
        allow(helper).to receive(:format_trigger_question_answers).and_return("66")
        expect(summary_component_rows).to include(
          { key: { text: "Indicate the total level of essential oils" },
            value: { html: "66" } },
        )
      end

      # rubocop:disable RSpec/ExampleLength
      it "renders a row with html for the elements value for trigger question with multiple elements" do
        entities_list = { inci_name: "ethanol", quantity: "66" }
        allow(trigger_question).to receive(:trigger_question_elements)
          .and_return([instance_double(TriggerQuestionElement), element])
        allow(helper).to receive(:format_trigger_question_elements).and_return(entities_list)
        allow(helper).to receive(:render).with("none_or_bullet_list",
                                               entities_list: entities_list,
                                               key_name: :inci_name,
                                               value_name: :quantity,
                                               list_classes: "")
                                         .and_return("Bullet list of elements")

        expect(summary_component_rows).to include(
          { key: { text: "Indicate the total level of essential oils" },
            value: { html: "Bullet list of elements" } },
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
