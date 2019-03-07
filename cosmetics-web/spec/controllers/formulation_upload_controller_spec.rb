require 'rails_helper'

RSpec.describe FormulationUploadController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }
  let(:notification) { create(:notification) }
  let(:component) { create(:component) }
  let(:text_file) { fixture_file_upload('/testText.txt', 'text/plain') }
  let(:image_file) { fixture_file_upload('/testImage.png', 'image/png') }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET #new" do
    it "assigns the correct responsible person model" do
      get(:new, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number, component_id: component.id })
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "assigns the correct notification model" do
      get(:new, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number, component_id: component.id })
      expect(assigns(:notification)).to eq(notification)
    end

    it "assigns the correct component model" do
      get(:new, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number, component_id: component.id })
      expect(assigns(:component)).to eq(component)
    end
  end

  describe "POST #create" do
    it "assigns the correct responsible person model" do
      post(:create, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number, component_id: component.id })
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "assigns the correct notification model" do
      post(:create, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number, component_id: component.id })
      expect(assigns(:notification)).to eq(notification)
    end

    it "assigns the correct component model" do
      post(:create, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number, component_id: component.id })
      expect(assigns(:component)).to eq(component)
    end

    it "adds an error if no file uploaded" do
      post(:create, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number,
      component_id: component.id })
      expect(assigns(:error_list).length).to eq(1)
    end

    it "re-renders the upload form if no file uploaded" do
      post(:create, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number,
      component_id: component.id })
      expect(response).to render_template(:new)
    end

    it "adds errors from the component model to the errors list" do
      post(:create, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number,
      component_id: component.id, formulation_file: image_file })
      expect(assigns(:error_list).length).to eq(1)
    end

    it "adds the formulation file to the component when the uploaded file is valid" do
      post(:create, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number,
      component_id: component.id, formulation_file: text_file })
      expect(component.reload.formulation_file.attached?).to be true
    end

    it "redirects to the notification controller formualtion upload endpoint when the uploaded file is valid" do
      post(:create, params: { responsible_person_id: responsible_person.id, notification_reference_number: notification.reference_number,
      component_id: component.id, formulation_file: text_file })
      expect(response).to redirect_to(formulation_upload_responsible_person_notification_path(responsible_person, notification))
    end
  end
end
