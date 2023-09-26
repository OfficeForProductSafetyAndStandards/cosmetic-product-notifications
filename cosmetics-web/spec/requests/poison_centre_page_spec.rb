require "rails_helper"

RSpec.describe "Poison centre page", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person, :with_a_contact_person, :with_previous_addresses) }
  let(:notification_exact) { create(:draft_notification, responsible_person:) }
  let(:params_exact) do
    {
      reference_number: notification_exact.reference_number,
    }
  end
  let(:notification_frame_formulation) { create(:draft_notification, responsible_person:) }
  let(:params_frame_formulation) do
    {
      reference_number: notification_frame_formulation.reference_number,
    }
  end

  before do
    notification_exact.components.first.update(notification_type: "exact")
    component_exact = create(:exact_component, notification: notification_exact)
    create(:cmr, name: "Foo CMR", component: component_exact)
    create(:exact_ingredient, exact_concentration: 4, inci_name: "Foo Ingredient", component: component_exact)

    nano_material = create(:nano_material, notification: notification_exact, inci_name: "Foo Nanomaterial")
    create(:component_nano_material, component: component_exact, nano_material:)

    create(:predefined_component, :completed, notification: notification_frame_formulation)
  end

  after do
    sign_out(:search_user)
  end

  describe "GET #show" do
    context "with a Poison Centre user" do
      before do
        sign_in_as_poison_centre_user
      end

      it "displays the cosmetics product name" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to include(notification_exact.product_name)
      end

      it "displays the product ingredients" do
        get poison_centre_notification_path(params_exact)
        within("section#item-2") do
          expect(page).to have_tag("h3", text: /Ingredients/)
          expect(page).to have_tag("dt", text: /Foo Ingredient/)
        end
      end

      it "does not display the product frame formulations for a product with only exact or range ingredients" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to include("Frame formulation")
      end

      it "displays the product frame formulations for a product with only frame formulations" do
        get poison_centre_notification_path(params_frame_formulation)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dt", text: /Frame formulation/)
        end
      end

      it "displays the product CMRs" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dd", text: /Foo CMR/)
        end
      end

      it "displays the product Nanomaterials" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dd", text: /Foo Nanomaterial/)
        end
      end

      it "displays the Responsible Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Responsible Person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.name))
      end

      it "displays the Responsible Person's current address" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.address_line_1))
      end

      it "does not display the Responsible Person's previous address(es)" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to have_tag("dd", text: optional_spaces(responsible_person.address_logs.first.line_1))
        expect(response.body).not_to have_tag("dd", text: optional_spaces(responsible_person.address_logs.second.line_1))
      end

      it "displays the Contact Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Assigned contact")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.contact_persons.first.name))
      end
    end

    context "with an OPSS General user" do
      before do
        sign_in_as_opss_general_user
      end

      it "displays the cosmetics product name" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to include(notification_exact.product_name)
      end

      it "does not display the product ingredients" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to include("Ingredients")
        expect(response.body).not_to include("Foo Ingredient")
      end

      it "does not display the product frame formulations for a product with only exact or range ingredients" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to include("Frame formulation")
      end

      it "does not display the product frame formulations for a product with only frame formulations" do
        get poison_centre_notification_path(params_frame_formulation)
        expect(response.body).not_to include("Frame formulation")
      end

      it "displays the product CMRs" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dd", text: /Foo CMR/)
        end
      end

      it "displays the product Nanomaterials" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dd", text: /Foo Nanomaterial/)
        end
      end

      it "displays the Responsible Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Responsible Person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.name))
      end

      it "displays the Responsible Person's current address" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.address_line_1))
      end

      it "does not display the Responsible Person's previous address(es)" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to have_tag("dd", text: optional_spaces(responsible_person.address_logs.first.line_1))
        expect(response.body).not_to have_tag("dd", text: optional_spaces(responsible_person.address_logs.second.line_1))
      end

      it "displays the Contact Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Assigned contact")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.contact_persons.first.name))
      end
    end

    context "with an OPSS Enforcement user" do
      before do
        sign_in_as_opss_enforcement_user
      end

      it "displays the cosmetics product name " do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to include(notification_exact.product_name)
      end

      it "displays the product ingredients" do
        get poison_centre_notification_path(params_exact)
        within("section#item-2") do
          expect(page).to have_tag("h3", text: /Ingredients/)
          expect(page).to have_tag("dt", text: /Foo Ingredient/)
        end
      end

      it "does not display the product frame formulations for a product with only exact or range ingredients" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to include("Frame formulation")
      end

      it "displays the product frame formulations for a product with only frame formulations" do
        get poison_centre_notification_path(params_frame_formulation)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dt", text: /Frame formulation/)
        end
      end

      it "displays the product CMRs" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("dd", text: /Foo CMR/)
      end

      it "displays the product Nanomaterials" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("dd", text: /Foo Nanomaterial/)
      end

      it "displays the Responsible Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Responsible Person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.name))
      end

      it "displays the Responsible Person's current address" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.address_line_1))
      end

      it "does not display the Responsible Person's previous address(es)" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to have_tag("dd", text: optional_spaces(responsible_person.address_logs.first.line_1))
        expect(response.body).not_to have_tag("dd", text: optional_spaces(responsible_person.address_logs.second.line_1))
      end

      it "displays the Contact Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Assigned contact")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.contact_persons.first.name))
      end
    end

    context "with an OPSS IMT user" do
      before do
        sign_in_as_opss_imt_user
      end

      it "displays the cosmetics product name " do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to include(notification_exact.product_name)
      end

      it "displays the product ingredients" do
        get poison_centre_notification_path(params_exact)
        within("section#item-2") do
          expect(page).to have_tag("h3", text: /Ingredients/)
          expect(page).to have_tag("dt", text: /Foo Ingredient/)
        end
      end

      it "does not display the product frame formulations for a product with only exact or range ingredients" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to include("Frame formulation")
      end

      it "displays the product frame formulations for a product with only frame formulations" do
        get poison_centre_notification_path(params_frame_formulation)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dt", text: /Frame formulation/)
        end
      end

      it "displays the product CMRs" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("dd", text: /Foo CMR/)
      end

      it "displays the product Nanomaterials" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("dd", text: /Foo Nanomaterial/)
      end

      it "displays the Responsible Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Responsible Person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.name))
      end

      it "displays the Responsible Person's current address" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.address_line_1))
      end

      it "does not display the Responsible Person's previous address(es)" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to have_tag("dd", text: optional_spaces(responsible_person.address_logs.first.line_1))
        expect(response.body).not_to have_tag("dd", text: optional_spaces(responsible_person.address_logs.second.line_1))
      end

      it "displays the Contact Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Assigned contact")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.contact_persons.first.name))
      end
    end

    context "with an OPSS Science user" do
      before do
        sign_in_as_opss_science_user
      end

      it "displays the cosmetics product name" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to include(notification_exact.product_name)
      end

      it "displays the product ingredients" do
        get poison_centre_notification_path(params_exact)
        within("section#item-2") do
          expect(page).to have_tag("h3", text: /Ingredients/)
          expect(page).to have_tag("dt", text: /Foo Ingredient/)
        end
      end

      it "does not display the product frame formulations for a product with only exact or range ingredients" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to include("Frame formulation")
      end

      it "displays the product frame formulations for a product with only frame formulations" do
        get poison_centre_notification_path(params_frame_formulation)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dt", text: /Frame formulation/)
        end
      end

      it "displays the product CMRs" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dd", text: /Foo CMR/)
        end
      end

      it "displays the product Nanomaterials" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dd", text: /Foo Nanomaterial/)
        end
      end

      it "displays the Responsible Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Responsible Person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.name))
      end

      it "displays the Responsible Person's current address" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.address_line_1))
      end

      it "does not display the Responsible Person's previous address(es)" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to have_tag("dd", text: optional_spaces(responsible_person.address_logs.first.line_1))
        expect(response.body).not_to have_tag("dd", text: optional_spaces(responsible_person.address_logs.second.line_1))
      end

      it "displays the Contact Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Assigned contact")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.contact_persons.first.name))
      end
    end

    context "with a Trading Standards user" do
      before do
        sign_in_as_trading_standards_user
      end

      it "displays the cosmetics product name " do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to include(notification_exact.product_name)
      end

      it "displays the product ingredients" do
        get poison_centre_notification_path(params_exact)
        within("section#item-2") do
          expect(page).to have_tag("h3", text: /Ingredients/)
          expect(page).to have_tag("dt", text: /Foo Ingredient/)
        end
      end

      it "does not display the product frame formulations for a product with only exact or range ingredients" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).not_to include("Frame formulation")
      end

      it "does not display the product frame formulations for a product with only frame formulations" do
        get poison_centre_notification_path(params_frame_formulation)
        expect(response.body).not_to include("Frame formulation")
      end

      it "displays the product CMRs" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dd", text: /Foo CMR/)
        end
      end

      it "displays the product Nanomaterials" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("section#item-2") do
          with_tag("dd", text: /Foo Nanomaterial/)
        end
      end

      it "displays the Responsible Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Responsible Person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.name))
      end

      it "displays the Responsible Person's current address" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.address_line_1))
      end

      it "displays the Responsible Person's previous address(es) in newest first order" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to match(/#{responsible_person.address_logs.first.line_1}.*#{responsible_person.address_logs.second.line_1}/m)
      end

      it "displays the Contact Person" do
        get poison_centre_notification_path(params_exact)
        expect(response.body).to have_tag("h2", text: "Assigned contact")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.contact_persons.first.name))
      end
    end
  end
end
