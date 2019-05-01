require 'rails_helper'

RSpec.describe ComponentBuildController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }
  let(:notification) { create(:notification, components: [create(:component)], responsible_person: responsible_person) }
  let(:component) { notification.components.first }

  let(:params) {
    {
      responsible_person_id: responsible_person.id,
      notification_reference_number: notification.reference_number,
      component_id: component.id
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
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :number_of_shades))
    end

    it "does not allow the user to create a notification component for a Responsible Person they not belong to" do
      expect {
        get(:new, params: other_responsible_person_params)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "GET #show" do
    it "assigns the correct notification" do
      get(:show, params: params.merge(id: :number_of_shades))
      expect(assigns(:component)).to eq(component)
    end

    it "renders the step template" do
      get(:show, params: params.merge(id: :number_of_shades))
      expect(response).to render_template(:number_of_shades)
    end

    it "redirects to the trigger rules page on finish" do
      get(:show, params: params.merge(id: :wicked_finish))
      expect(response).to redirect_to(new_responsible_person_notification_component_trigger_question_path(responsible_person, notification, component))
    end

    it "initialises shades array with two empty strings in add_shades step" do
      get(:show, params: params.merge(id: :add_shades))
      expect(assigns(:component).shades).to eq(["", ""])
    end

    it "does not allow the user to view a notification component for a Responsible Person they not belong to" do
      expect {
        get(:show, params: other_responsible_person_params.merge(id: :number_of_shades))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "does not allow the user to update a notification component that has already been submitted" do
      notification.update state: "notification_complete"
      expect {
        get(:show, params: params.merge(id: :number_of_shades))
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "POST #update" do
    it "assigns the correct notification" do
      post(:update, params: params.merge(id: :number_of_shades, component: { shades: [] }))
      expect(assigns(:component)).to eq(component)
    end

    it "updates notification parameters if present" do
      post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue] }))
      expect(component.reload.shades).to eq(%w[red blue])
    end

    it "proceeds to add_shades step if user wants to add shades" do
      post(:update, params: params.merge(id: :number_of_shades, number_of_shades: "multiple-shades-same-notification"))
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :add_shades))
    end

    it "skips add_shades step if user chooses to submit separate notifications for each shade" do
      post(:update, params: params.merge(id: :number_of_shades, number_of_shades: "multiple-shades-different-notification"))
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :add_cmrs))
    end

    it "skips add_shades step if product has single or no shades" do
      post(:update, params: params.merge(id: :number_of_shades, number_of_shades: "single-or-no-shades"))
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :add_cmrs))
    end

    it "adds errors if number_of_shades is empty" do
      post(:update, params: params.merge(id: :number_of_shades, number_of_shades: nil))
      expect(assigns(:component).errors[:shades]).to include("Please select an option")
    end

    it "adds empty string to shades array if add_shade parameter passed" do
      post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue] }, add_shade: true))
      expect(assigns(:component).shades).to eq(["red", "blue", ""])
    end

    it "removes shade from list if passed remove_shade_with_id" do
      post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue yellow] }, remove_shade_with_id: 1))
      expect(assigns(:component).shades).to eq(%w[red yellow])
    end

    it "adds an empty string to shades if removing an element would leave less than two" do
      post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue] }, remove_shade_with_id: 0))
      expect(assigns(:component).shades).to eq(["blue", ""])
    end

    it "does not allow the user to update a notification component for a Responsible Person they not belong to" do
      expect {
        post(:update, params: other_responsible_person_params.merge(id: :add_shades, component: { shades: %w[red blue] }))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "does not allow the user to update a notification that has already been submitted" do
      notification.update state: "notification_complete"
      expect {
        post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue] }))
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

private

  def other_responsible_person_params
    other_responsible_person = create(:responsible_person, email_address: "another.person@example.com")
    other_notification = create(:notification, components: [create(:component)], responsible_person: other_responsible_person)
    other_component = other_notification.components.first

    {
      responsible_person_id: other_responsible_person.id,
      notification_reference_number: other_notification.reference_number,
      component_id: other_component.id
    }
  end
end
