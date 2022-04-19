require "rails_helper"

RSpec.describe ResponsiblePersons::Wizard::NotificationNanomaterialController, type: :controller do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:notification) { create(:notification, responsible_person: responsible_person) }
  let(:component) { create(:component, notification: notification) }

  let(:nanomaterial) do
    create(:nano_material,
           notification: notification,
           nano_elements: [
             create(:nano_element, inci_name: "nanomaterial1"),
             create(:nano_element, inci_name: "nanomaterial2"),
           ])
  end
  let(:nano_element1) { nanomaterial.nano_elements.first }
  let(:nano_element2) { nanomaterial.nano_elements.second }

  let(:params) do
    {
      responsible_person_id: responsible_person.id,
      notification_reference_number: notification.reference_number,
      nanomaterial_nano_element_id: nano_element1,
    }
  end

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET #new" do
    it "redirects to the first step of the wizard" do
      get(:new, params: params)
      expect(response).to redirect_to(responsible_person_notification_nanomaterial_build_path(responsible_person, notification, nano_element1, :add_nanomaterial_name))
    end
  end

  describe "GET #show" do
    context "when the notification is already submitted" do
      subject(:request) { get(:show, params: params.merge({ id: "confirm_usage" })) }

      let(:notification) { create(:registered_notification, responsible_person: responsible_person) }

      it "redirects to the notifications page" do
        expect(request).to redirect_to(responsible_person_notification_path(responsible_person, notification))
      end
    end

    it "assigns the correct notification" do
      get(:show, params: params.merge(id: :select_purposes))
      expect(assigns(:notification)).to eq(notification)
    end

    it "assigns the correct nano-element" do
      get(:show, params: params.merge(id: :select_purposes))
      expect(assigns(:nano_element)).to eq(nano_element1)
    end

    it "renders the step template" do
      get(:show, params: params.merge(id: :select_purposes))
      expect(response).to render_template(:select_purposes)
    end

    describe "at confirm_restrictions" do
      it "redirects to the non-standard nanomaterial path when nano-element purposes include 'other'" do
        nano_element1.update(purposes: %w[other])
        get(:show, params: params.merge(id: :after_select_purposes_routing))
        expect(response).to redirect_to(responsible_person_notification_nanomaterial_build_path(responsible_person, notification, nano_element1, :non_standard_nanomaterial_notified))
      end
    end
  end

  describe "POST #update" do
    describe "at select_purposes"  do
      let(:select_purposes_params) { params.merge(id: :select_purposes) }

      it "updates the nano-element with the selected purposes" do
        post(:update, params: select_purposes_params.merge(nano_element: { "colorant": "0", "preservative": "1", "uv_filter": "1", "other": "0" }))
        expect(nano_element1.reload.purposes).to eq(%w[preservative uv_filter])
      end

      it "ignores invalid purpose values" do
        post(:update, params: select_purposes_params.merge(nano_element: { "colorant": "1", "invalid_purpose": "1", "other": "0" }))
        expect(nano_element1.reload.purposes).to eq(%w[colorant])
      end

      it "redirects to the next page when purposes are selected" do
        post(:update, params: select_purposes_params.merge(nano_element: { "preservative": "1" }))
        expect(response).to redirect_to(responsible_person_notification_nanomaterial_build_path(responsible_person, notification, nano_element1, :after_select_purposes_routing))
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
        expect(response).to redirect_to(responsible_person_notification_nanomaterial_build_path(responsible_person, notification, nano_element1, :confirm_usage))
      end

      it "redirects to the 'nanomaterial must be listed' error page when confirm_restrictions is 'no'" do
        post(:update, params: confirm_restrictions_params.merge(nano_element: { confirm_restrictions: "no" }))
        expect(response).to redirect_to(responsible_person_notification_nanomaterial_build_path(responsible_person, notification, nano_element1, :must_be_listed))
      end

      it "sets error when no option is selected" do
        post(:update, params: confirm_restrictions_params)
        expect(assigns(:nano_element).errors[:confirm_restrictions]).to include("Select an option")
      end
    end
  end
end
