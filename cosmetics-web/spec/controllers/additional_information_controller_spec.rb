require 'rails_helper'

RSpec.describe AdditionalInformationController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }
  let(:predefined_component) { create(:predefined_component) }
  let(:ranges_component) { create(:ranges_component) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET #index" do
    it "redirects to the check your answers page if all components have complete formulations and don't require images" do
      notification = Notification.create(responsible_person_id: responsible_person.id, components: [predefined_component])
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

    it "raised a NotAuthorizedError if the notification has already been submitted" do
      notification = Notification.create(responsible_person_id: responsible_person.id, components: [predefined_component], state: "notification_complete")
      expect {
        get :index, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
