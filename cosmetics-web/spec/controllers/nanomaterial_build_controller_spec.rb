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
      expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :select_purpose))
    end
  end

  describe "GET #show" do
    it "assigns the correct component" do
      get(:show, params: params.merge(id: :select_purpose))
      expect(assigns(:component)).to eq(component)
    end

    it "assigns the correct nano-element" do
      get(:show, params: params.merge(id: :select_purpose))
      expect(assigns(:nano_element)).to eq(nano_element1)
    end

    it "renders the step template" do
      get(:show, params: params.merge(id: :select_purpose))
      expect(response).to render_template(:select_purpose)
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
      let(:confirm_restrictions_params) { params.merge(id: :confirm_restrictions) }

      it "assigns the correct purpose on confirm_restrictions" do
        get(:show, params: confirm_restrictions_params.merge(purpose: 'uv_filter'))
        expect(assigns(:purpose)).to eq('uv_filter')
      end

      it "redirect the unhappy path when purpose is unexpected" do
        get(:show, params: confirm_restrictions_params.merge(purpose: 'other'))
        expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :unhappy_path))
      end

      it "redirect the unhappy path when purpose is not defined" do
        get(:show, params: confirm_restrictions_params)
        expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :unhappy_path))
      end
    end
  end

  describe "POST #update" do
    describe "at select_purpose"  do
      let(:select_purpose_params) { params.merge(id: :select_purpose) }

      it "redirects to the next page with the selected purpose" do
        selected_purpose = "selected_purpose"
        post(:update, params: select_purpose_params.merge(nano_element: { purpose: selected_purpose }))
        expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :confirm_restrictions, purpose: selected_purpose))
      end

      it "set errors when no option is selected" do
        post(:update, params: select_purpose_params)
        expect(assigns(:nano_element).errors).to have(1).items
      end
    end

    describe "at confirm_restrictions" do
      let(:confirm_restrictions_params) { params.merge(id: :confirm_restrictions) }

      it "redirects to the next page when the confirm_restrictions is true" do
        post(:update, params: confirm_restrictions_params.merge(nano_element: { confirm_restrictions: "true" }))
        expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :confirm_usage))
      end

      it "redirects to the next unhappy path when the confirm_restrictions is false" do
        post(:update, params: confirm_restrictions_params.merge(nano_element: { confirm_restrictions: "false" }))
        expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :unhappy_path))
      end

      it "set errors when no option is selected" do
        post(:update, params: confirm_restrictions_params)
        expect(assigns(:nano_element).errors).to have(1).items
      end
    end

    describe "at confirm_usage" do
      let(:confirm_usage_params) { params.merge(id: :confirm_usage) }

      it "redirects to the next page when the confirm_usage is true" do
        post(:update, params: confirm_usage_params.merge(nano_element: { confirm_usage: "true" }))
        expect(response).to redirect_to(new_responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element2))
      end

      it "redirects to the next unhappy path when the confirm_usage is false" do
        post(:update, params: confirm_usage_params.merge(nano_element: { confirm_usage: "false" }))
        expect(response).to redirect_to(responsible_person_notification_component_nanomaterial_build_path(responsible_person, notification, component, nano_element1, :unhappy_path))
      end

      it "set errors when no option is selected" do
        post(:update, params: confirm_usage_params)
        expect(assigns(:nano_element).errors).to have(1).items
      end
    end
  end
end
