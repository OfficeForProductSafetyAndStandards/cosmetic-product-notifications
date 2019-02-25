require 'rails_helper'

RSpec.describe ComponentBuildController, type: :controller do
  let(:notification) { create(:notification, components: [create(:component)]) }
  let(:component) { notification.components.first }

  before do
    sign_in_as_member_of_responsible_person(create(:responsible_person))
  end

  after do
    sign_out
  end

  describe "GET #new" do
    it "redirects to the first step of the wizard" do
      get(:new, params: { notification_reference_number: notification.reference_number, component_id: component.id })
      expect(response).to redirect_to(notification_component_build_path(notification, component, "number_of_shades"))
    end
  end

  describe "GET #show" do
    it "assigns the correct notification" do
      get(:show, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                           id: 'number_of_shades' })
      expect(assigns(:component)).to eq(component)
    end

    it "renders the step template" do
      get(:show, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                           id: 'number_of_shades' })
      expect(response).to render_template(:number_of_shades)
    end

    it "redirects to the check your answers page on finish" do
      get(:show, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                           id: 'wicked_finish' })
      expect(response).to redirect_to(notification_build_path(component.notification, "add_product_image"))
    end

    it "initialises shades array with two empty strings in add_shades step" do
      get(:show, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                           id: 'add_shades' })
      expect(assigns(:component).shades).to eq(['', ''])
    end
  end

  describe "POST #update" do
    it "assigns the correct notification" do
      post(:update, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                              id: 'number_of_shades', component: { shades: [] } })
      expect(assigns(:component)).to eq(component)
    end

    it "updates notification parameters if present" do
      post(:update, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                              id: 'add_shades', component: { shades: %w[red blue] } })
      expect(component.reload.shades).to eq(%w[red blue])
    end

    it "proceeds to add_shades step if user wants to add shades" do
      post(:update, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                              id: 'number_of_shades', number_of_shades: 'multiple' })
      expect(response).to redirect_to(notification_component_build_path(notification, component.id, "add_shades"))
    end

    it "skips add_shades step if user doesn't want to add shades" do
      post(:update, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                              id: 'number_of_shades', number_of_shades: 'single' })
      expect(response).to redirect_to(notification_build_path(component.notification, "add_product_image"))
    end

    it "adds errors if number_of_shades is empty" do
      post(:update, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                              id: 'number_of_shades', number_of_shades: nil })
      expect(assigns(:component).errors[:shades]).to include('Please select an option')
    end

    it "adds empty string to shades array if add_shade parameter passed" do
      post(:update, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                              id: 'add_shades', component: { shades: %w[red blue] }, add_shade: true })
      expect(assigns(:component).shades).to eq(['red', 'blue', ''])
    end

    it "removes shade from list if passed remove_shade_with_id" do
      post(:update, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                              id: 'add_shades', component: { shades: %w[red blue yellow] }, remove_shade_with_id: 1 })
      expect(assigns(:component).shades).to eq(%w[red yellow])
    end

    it "adds an empty string to shades if removing an element would leave less than two" do
      post(:update, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                              id: 'add_shades', component: { shades: %w[red blue] }, remove_shade_with_id: 0 })
      expect(assigns(:component).shades).to eq(['blue', ''])
    end

    it "re-renders add_shades if less than two non blank shades are present" do
      post(:update, params: { notification_reference_number: notification.reference_number, component_id: component.id,
                              id: 'add_shades', component: { shades: ['red', ''] } })
      expect(response).to render_template("component_build/add_shades")
    end
  end
end
