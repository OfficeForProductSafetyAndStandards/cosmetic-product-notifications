require 'rails_helper'

RSpec.describe ManualEntryController, type: :controller do
  before do
    authenticate_user
  end

  describe "GET #create" do
    it "creates new notification object" do
      get :create
      expect(assigns(:notification)).to be_kind_of(Notification)
    end

    it "redirects to the first step of the manual web form" do
      get :create
      expect(response).to redirect_to(notification_manual_entry_path(assigns(:notification).id, "add_product_name"))
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
  end
end
