require 'rails_helper'

RSpec.describe NanomaterialBuildController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }
  let(:notification) { create(:notification, components: [create(:component)], responsible_person: responsible_person) }
  let(:component) { notification.components.first }

  let(:nanomaterial) {
    create(:nano_material,
           component: component,
           nano_elements: [
               create(:nano_element, inci_name: "nanomaterial1"),
               create(:nano_element, inci_name: "nanomaterial2")
           ])
  }
  let(:nano_element1) { nanomaterial.nano_elements.first }
  let(:nano_element2) { nanomaterial.nano_elements.second }

  let(:params) {
    {
        responsible_person_id: responsible_person.id,
        notification_reference_number: notification.reference_number,
        component_id: component.id,
        nanomaterial_nano_element_id: nano_element1
    }
  }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET #new" do
    it "redirects to the first step of the wizard" do
      get(:new, params: params)
      expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :select_purposes))
    end
  end

  describe "GET #show" do
    it "assigns the correct component" do
      get(:show, params: params.merge(id: :select_purposes))
      expect(assigns(:component)).to eq(component)
    end

    it "assigns the correct nano-element" do
      get(:show, params: params.merge(id: :select_purposes))
      expect(assigns(:nano_element)).to eq(nano_element1)
    end

    it "renders the step template" do
      get(:show, params: params.merge(id: :select_purposes))
      expect(response).to render_template(:select_purposes)
    end

    describe "at wicked_finish" do
      it "redirects to a new nanomaterial build page, with the next nano-element, on finish" do
        get(:show, params: params.merge(id: :wicked_finish))
        expect(response).to redirect_to(new_responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element2))
      end

      it "redirects back to the component build path, on finish the last nano-element" do
        get(:show, params: params.merge(id: :wicked_finish, nanomaterial_nano_element_id: nano_element2))
        expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :select_category))
      end
    end

    describe "at confirm_restrictions" do
      it "redirects to the non-standard nanomaterial path when nano-element purposes include 'other'" do
        nano_element1.update(purposes: %w(other))
        get(:show, params: params.merge(id: :confirm_restrictions))
        expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :non_standard_nanomaterial_notified))
      end
    end
  end

  describe "POST #update" do
    describe "at select_purposes"  do
      let(:select_purposes_params) { params.merge(id: :select_purposes) }

      it "updates the nano-element with the selected purposes" do
        post(:update, params: select_purposes_params.merge(nano_element: { "colorant": "0", "preservative": "1", "uv_filter": "1", "other": "0" }))
        expect(nano_element1.reload.purposes).to eq(%w(preservative uv_filter))
      end

      it "ignores invalid purpose values" do
        post(:update, params: select_purposes_params.merge(nano_element: { "colorant": "1", "invalid_purpose": "1", "other": "0" }))
        expect(nano_element1.reload.purposes).to eq(%w(colorant))
      end

      it "redirects to the next page when purposes are selected" do
        post(:update, params: select_purposes_params.merge(nano_element: { "preservative": "1" }))
        expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :confirm_restrictions))
      end

      it "sets error when no purpose is selected" do
        post(:update, params: select_purposes_params)
        expect(assigns(:nano_element).errors[:purposes]).to include("Choose an option")
      end
    end

    describe "at confirm_restrictions" do
      let(:confirm_restrictions_params) { params.merge(id: :confirm_restrictions) }

      it "redirects to the next page when confirm_restrictions is 'yes'" do
        post(:update, params: confirm_restrictions_params.merge(nano_element: { confirm_restrictions: "yes" }))
        expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :confirm_usage))
      end

      it "redirects to the non-standard nonomaterial notified path when confirm_restrictions is 'no'" do
        post(:update, params: confirm_restrictions_params.merge(nano_element: { confirm_restrictions: "no" }))
        expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :non_standard_nanomaterial_notified))
      end

      it "sets error when no option is selected" do
        post(:update, params: confirm_restrictions_params)
        expect(assigns(:nano_element).errors[:confirm_restrictions]).to include("Select an option")
      end
    end

    describe "at confirm_usage" do
      let(:confirm_usage_params) { params.merge(id: :confirm_usage) }

      it "redirects to the next page when confirm_usage is 'yes'" do
        post(:update, params: confirm_usage_params.merge(nano_element: { confirm_usage: "yes" }))
        expect(response).to redirect_to(new_responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element2))
      end

      it "redirects to the non-standard nanomaterial path when confirm_usage is 'no'" do
        post(:update, params: confirm_usage_params.merge(nano_element: { confirm_usage: "no" }))
        expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :non_standard_nanomaterial_notified))
      end

      it "sets error when no option is selected" do
        post(:update, params: confirm_usage_params)
        expect(assigns(:nano_element).errors[:confirm_usage]).to include("Select an option")
      end
    end

    describe " at non_standard_nanomaterial_notified" do
      context "answered yes" do
        let(:confirm_toxicology_notified) do
          params.merge(id: :non_standard_nanomaterial_notified, nano_element: { confirm_toxicology_notified: "yes" })
        end

        it "redirects to 'when_products_containing_nanomaterial_can_be_placed_on_market'" do
          post(:update, params: confirm_toxicology_notified)
          expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :when_products_containing_nanomaterial_can_be_placed_on_market))
        end
      end

      context "answered no" do
        let(:confirm_toxicology_notified) do
          params.merge(id: :non_standard_nanomaterial_notified, nano_element: { confirm_toxicology_notified: "no" })
        end

        it "redirects to 'notify_your_nanomaterial'" do
          post(:update, params: confirm_toxicology_notified)
          expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :notify_your_nanomaterial))
        end
      end

      context "answered not sure" do
        let(:confirm_toxicology_notified) do
          params.merge(id: :non_standard_nanomaterial_notified, nano_element: { confirm_toxicology_notified: "not sure" })
        end

        it "redirects to to the same path as answering no" do
          post(:update, params: confirm_toxicology_notified)
          expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :notify_your_nanomaterial))
        end
      end
    end
  end
end
