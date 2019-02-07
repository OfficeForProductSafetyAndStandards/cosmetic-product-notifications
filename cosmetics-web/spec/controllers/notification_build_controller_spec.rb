require 'rails_helper'

RSpec.describe NotificationBuildController, type: :controller do
  before do
    sign_in_as_member_of_responsible_person(create(:responsible_person))
  end

  after do
    sign_out
  end

  describe "GET #new" do
    it "redirects to the first step of the manual web form" do
      notification = Notification.create
      get(:new, params: { notification_id: notification.id })
      expect(response).to redirect_to(
        notification_build_path(notification.id, "add_product_name")
)
    end
  end

  describe "GET #show" do
    it "assigns the correct notification" do
      notification = Notification.create
      get(:show, params: { notification_id: notification.id, id: 'add_product_name' })
      expect(assigns(:notification)).to eq(notification)
    end

    it "renders the step template" do
      notification = Notification.create
      get(:show, params: { notification_id: notification.id, id: 'add_product_name' })
      expect(response).to render_template(:add_product_name)
    end

    it "redirects to the check your answers page on finish" do
      notification = Notification.create
      get(:show, params: { notification_id: notification.id, id: 'wicked_finish' })
      expect(response).to redirect_to(edit_notification_path(notification))
    end
  end

  describe "POST #update" do
    it "assigns the correct notification" do
      notification = Notification.create
      post(:update, params: { notification_id: notification.id, id: 'add_product_name',
                  notification: { product_name: 'Super Shampoo' } })
      expect(assigns(:notification)).to eq(notification)
    end

    it "updates notification parameters if present" do
      notification = Notification.create
      post(:update, params: { notification_id: notification.id, id: 'add_product_name',
                    notification: { product_name: 'Super Shampoo' } })
      expect(notification.reload.product_name).to eq('Super Shampoo')
    end

    it "creates a component if single_or_multi_component set to single" do
      notification = Notification.create
      post(:update, params: { notification_id: notification.id, id: 'single_or_multi_component',
                    single_or_multi_component: "single" })
      expect(notification.components).to have(1).item
    end

    # TODO COSBETA-10 Update this test
    it "throws an exception if single_or_multi_component set to multiple" do
      notification = Notification.create
      post(:update, params: { notification_id: notification.id, id: 'single_or_multi_component',
                  single_or_multi_component: "multiple" })
      expect(notification.components).to have(1).item
    end

    it "adds errors if single_or_multi_component is empty" do
      notification = Notification.create
      post(:update, params: { notification_id: notification.id, id: 'single_or_multi_component',
                              single_or_multi_component: nil })
      expect(assigns(:notification).errors[:components]).to include('Must not be nil')
    end

    it "redirects to add_import_country step if is_imported set to true" do
      notification = Notification.create
      post(:update, params: { notification_id: notification.id, id: 'is_imported',
                              is_imported: "true" })
      expect(response).to redirect_to(notification_build_path(notification, :add_import_country))
    end

    it "skips add_import_country step if is_imported set to false" do
      notification = Notification.create
      post(:update, params: { notification_id: notification.id, id: 'is_imported',
                              is_imported: "false" })
      expect(response).to redirect_to(notification_build_path(notification, :single_or_multi_component))
    end

    it "adds an error if user doesn't pick a radio option for is_imported" do
      notification = Notification.create
      post(:update, params: { notification_id: notification.id, id: 'is_imported',
                              is_imported: nil })
      expect(assigns(:notification).errors[:import_country]).to include('Must not be nil')
    end

    it "adds an error if user submits import_country with a blank value" do
      notification = Notification.create
      post(:update, params: { notification_id: notification.id, id: 'add_import_country',
                    notification: { import_country: '' } })
      expect(assigns(:notification).errors[:import_country]).to include('Must not be blank')
    end

    it "continues to next step if user submits import_country with a valid value" do
      notification = Notification.create
      post(:update, params: { notification_id: notification.id, id: 'add_import_country',
                    notification: { import_country: 'France' } })
      expect(response).to redirect_to(notification_build_path(notification, :single_or_multi_component))
    end
  end
end
