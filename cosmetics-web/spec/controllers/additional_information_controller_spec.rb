require "rails_helper"

RSpec.describe ResponsiblePersons::AdditionalInformationController, :with_stubbed_antivirus, type: :controller do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:predefined_component) { create(:predefined_component) }
  let(:ranges_component) { create(:ranges_component) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET #index" do
    it "redirects to the check your answers page if all components have complete formulations and don't require images" do
      notification = Notification.create(responsible_person_id: responsible_person.id, was_notified_before_eu_exit: true, components: [predefined_component])
      notification.image_uploads.create
      get :index, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number }
      expect(response).to redirect_to(edit_responsible_person_notification_path(responsible_person, notification))
    end

    it "updates the notification state to draft_complete if all components have complete formulations and don't require images" do
      notification = Notification.create(responsible_person_id: responsible_person.id, components: [predefined_component], state: "notification_file_imported")
      get :index, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number }
      expect(notification.reload.state).to eq("draft_complete")
    end

    it "redirects to the formulation upload page if not all components have complete formulations or product images" do
      notification = Notification.create(responsible_person_id: responsible_person.id, components: [ranges_component])
      get :index, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number }
      expect(response).to redirect_to(new_responsible_person_notification_component_formulation_path(responsible_person, notification, ranges_component))
    end

    it "redirects to the formulation upload page if not all components have complete formulations" do
      notification = Notification.create(responsible_person_id: responsible_person.id, components: [ranges_component])
      notification.image_uploads.create
      get :index, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number }
      expect(response).to redirect_to(new_responsible_person_notification_component_formulation_path(responsible_person, notification, ranges_component))
    end

    it "redirects to the image upload page if not all components have product images" do
      notification = Notification.create(responsible_person_id: responsible_person.id, components: [predefined_component])
      get :index, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number }
      expect(response).to redirect_to(new_responsible_person_notification_product_image_upload_path(responsible_person, notification))
    end

    context "when the notification is already submitted" do
      subject(:request) { get(:index, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number }) }

      let(:notification) { create(:registered_notification, responsible_person: responsible_person, components: [predefined_component]) }

      it "redirects to the notifications page" do
        expect(request).to redirect_to(responsible_person_notification_path(responsible_person, notification))
      end
    end

    context "when a notification has multiple components" do
      let(:first_nano_elements) do
        [
          create(:nano_element, iupac_name: "NanoMaterial 1"), create(:nano_element, iupac_name: "NanoMaterial 2")
        ]
      end

      let(:second_nano_elements) do
        [
          create(:nano_element, iupac_name: "Element 1A"), create(:nano_element, iupac_name: "Element 2A")
        ]
      end

      let(:first_component) do
        create(:component, name: "Component 1", nano_material: create(:nano_material, nano_elements: first_nano_elements))
      end

      let(:second_component) do
        create(:component, name: "Component 2", nano_material: create(:nano_material, nano_elements: second_nano_elements))
      end

      let(:notification) do
        create(:notification, components: [first_component, second_component], responsible_person: responsible_person)
      end

      context "when all components have required nano materials" do
        it "redirects to the 2nd component's next required nano element" do
          nano_element = second_component.nano_material.nano_elements.find(&:required?)
          get :index, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number }

          expect(response).to redirect_to(new_responsible_person_notification_component_nanomaterial_build_path(notification.responsible_person, notification, second_component, nano_element))
        end
      end

      context "when one component is complete" do
        let(:second_nano_elements) do
          [
            create(:nano_element, iupac_name: "Element 1A", purposes: %w[other], confirm_toxicology_notified: "yes"),
            create(:nano_element, iupac_name: "Element 2A", purposes: %w[other], confirm_toxicology_notified: "yes"),
          ]
        end

        it "redirects to the correct component required nano element" do
          nano_element = first_component.nano_material.nano_elements.find(&:required?)
          get :index, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number }

          expect(response).to redirect_to(new_responsible_person_notification_component_nanomaterial_build_path(notification.responsible_person, notification, first_component, nano_element))
        end
      end
    end
  end
end
