require 'rails_helper'

RSpec.describe FormulationUploadController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }
  let(:notification) { create(:notification, responsible_person: responsible_person) }
  let(:component) { create(:component, notification: notification) }
  let(:other_responsible_person) { create(:responsible_person) }
  let(:other_notification) { create(:notification, responsible_person: other_responsible_person) }
  let(:other_component) { create(:component, notification: other_notification) }
  let(:pdf_file) { fixture_file_upload('/testPdf.pdf', 'application/pdf') }
  let(:image_file) { fixture_file_upload('/testImage.png', 'image/png') }

  let(:params) {
    {
      responsible_person_id: responsible_person.id,
      notification_reference_number: notification.reference_number,
      component_id: component.id
    }
  }

  let(:other_responsible_person_params) {
    {
      responsible_person_id: other_responsible_person.id,
      notification_reference_number: other_notification.reference_number,
      component_id: other_component.id
    }
  }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET #new" do
    it "assigns the correct component model" do
      get(:new, params: params)
      expect(assigns(:component)).to eq(component)
    end

    it "does not let the user view the page for a component for a responsible person they do not belong to" do
      expect {
        get(:new, params: other_responsible_person_params)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "POST #create" do
    it "assigns the correct component model" do
      post(:create, params: params)
      expect(assigns(:component)).to eq(component)
    end

    it "adds an error if no file uploaded" do
      post(:create, params: params)
      expect(assigns(:error_list).length).to eq(1)
    end

    it "re-renders the upload form if no file uploaded" do
      post(:create, params: params)
      expect(response).to render_template(:new)
    end

    it "adds errors from the component model to the errors list" do
      post(:create, params: params.merge(formulation_file: image_file))
      expect(assigns(:error_list).length).to eq(1)
    end

    it "adds the formulation file to the component when the uploaded file is valid" do
      post(:create, params: params.merge(formulation_file: pdf_file))
      expect(component.reload.formulation_file.attached?).to be true
    end

    it "redirects to the additional information controller when the uploaded file is valid" do
      post(:create, params: params.merge(formulation_file: pdf_file))
      expect(response).to redirect_to(responsible_person_notification_additional_information_index_path(responsible_person, notification))
    end

    it "does not let the user submit the form for a component for a responsible person they do not belong to" do
      expect {
        post(:create, params: other_responsible_person_params.merge(formulation_file: pdf_file))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "does not let the user submit the form for a component for a completed notification" do
      notification.update state: "notification_complete"
      expect {
        post(:create, params: params.merge(formulation_file: pdf_file))
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
