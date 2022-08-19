require "rails_helper"

RSpec.describe "Poison centre page", type: :request do
  include RSpecHtmlMatchers

  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:notification) { create(:draft_notification, responsible_person: responsible_person) }
  let(:params) do
    {
      reference_number: notification.reference_number,
    }
  end

  before do
    component = create(:exact_component, notification: notification)
    create(:cmr, name: "Foo CMR", component: component)
    create(:exact_ingredient, exact_concentration: 4, inci_name: "Foo Ingredient", component: component)

    nano_material = create(:nano_material, notification: notification)
    create(:component_nano_material, component: component, nano_material: nano_material)
    create(:nano_element, inci_name: "Foo Nanomaterial", nano_material: nano_material)
  end

  after do
    sign_out(:search_user)
  end

  describe "GET #show" do
    context "with a Poison Centre user" do
      before do
        sign_in_as_poison_centre_user
      end

      it "displays the cosmetics product name " do
        get poison_centre_notification_path(params)
        expect(response.body).to include(notification.product_name)
      end

      it "displays the product ingredients" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("h2", text: "Ingredients")
        expect(response.body).to have_tag("th", text: /Foo Ingredient/)
      end

      it "displays the product frame formulations" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("h2", text: "Frame formulations")
      end

      it "displays the product CMRs" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("td#cmr-names", text: /Foo CMR/)
      end

      it "displays the product Nanomaterials" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("td", text: /Foo Nanomaterial/)
      end

      it "displays the Responsible Person" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("h2", text: "Responsible Person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.name))
      end

      it "displays the Contact Person" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("h2", text: "Contact person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.contact_persons.first.name))
      end
    end

    context "with a Market Surveilance Authority user" do
      before do
        sign_in_as_msa_user
      end

      it "displays the cosmetics product name " do
        get poison_centre_notification_path(params)
        expect(response.body).to include(notification.product_name)
      end

      it "does not display the product ingredients" do
        get poison_centre_notification_path(params)
        expect(response.body).not_to include("Ingredients")
        expect(response.body).not_to include("Foo Ingredient")
      end

      it "does not display the product frame formulations" do
        get poison_centre_notification_path(params)
        expect(response.body).not_to include("Frame formulations")
      end

      it "displays the product CMRs" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("dd", text: /Foo CMR/)
      end

      it "displays the product Nanomaterials" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("dd", text: /Foo Nanomaterial/)
      end

      it "displays the Responsible Person" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("h2", text: "Responsible Person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.name))
      end

      it "displays the Contact Person" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("h2", text: "Contact person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.contact_persons.first.name))
      end
    end

    context "with a OPSS Science user" do
      before do
        sign_in_as_opss_science_user
      end

      it "displays the cosmetics product name " do
        get poison_centre_notification_path(params)
        expect(response.body).to include(notification.product_name)
      end

      it "displays the product ingredients" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("h2", text: "Ingredients")
        expect(response.body).to have_tag("th", text: /Foo Ingredient/)
      end

      it "displays the product frame formulations" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("h2", text: "Frame formulations")
      end

      it "displays the product CMRs" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("td#cmr-names", text: /Foo CMR/)
      end

      it "displays the product Nanomaterials" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("td", text: /Foo Nanomaterial/)
      end

      it "displays the Responsible Person" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("h2", text: "Responsible Person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.name))
      end

      it "displays the Contact Person" do
        get poison_centre_notification_path(params)
        expect(response.body).to have_tag("h2", text: "Contact person")
        expect(response.body).to have_tag("dd", text: optional_spaces(responsible_person.contact_persons.first.name))
      end
    end
  end
end
