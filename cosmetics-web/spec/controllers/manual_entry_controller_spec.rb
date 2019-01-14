require 'rails_helper'

RSpec.describe ManualEntryController, type: :controller do
  describe "GET #create" do
    it "creates new notification object" do
      get :create
      expect(assigns(:notification)).to be_kind_of(Notification)
    end

    it "redirects to the first step of the manual web form" do
      get :create
      expect(response).to redirect_to("/manual_entry/add_product_name")
    end
  end

  describe "GET #show" do
    it "assigns the correct notification" do
      notification = Notification.create
      get(:show,
          params: { 'id' => 'add_product_name' },
          session: { 'notification_id' => notification.id })
      expect(assigns(:notification)).to eq(notification)
    end

    it "renders the step template" do
      notification = Notification.create
      get(:show,
          params: { 'id' => 'add_product_name' },
          session: { 'notification_id' => notification.id })
      expect(response).to render_template(:add_product_name)
    end
  end

  describe "POST #update" do
    it "assigns the correct notification" do
      notification = Notification.create
      post(:update, params: { 'id' => 'add_product_name' }, session: { 'notification_id' => notification.id })
      expect(assigns(:notification)).to eq(notification)
    end

    it "updates notification parameters if present" do
      notification = Notification.create
      post(:update,
          params: { 'id' => 'add_product_name', 'notification' => { 'product_name' => 'Super Shampoo' } },
          session: { 'notification_id' => notification.id })
      expect(notification.reload.product_name).to eq('Super Shampoo')
    end

    it "marks the notification as complete on reaching the final step" do
      notification = Notification.create
      notification.aasm_state = 'draft_complete'
      notification.save
      post(:update, params: { 'id' => 'check_your_answers' }, session: { 'notification_id' => notification.id })
      expect(notification.reload.aasm_state).to eq('notification_complete')
    end
  end
end
