require 'rails_helper'

RSpec.describe ManualEntryController, type: :controller do
  before(:each) do
    authenticate_user
  end

  describe "GET #create" do
    it "creates new notification object" do
      get :create
      expect(assigns(:notification)).to be_kind_of(Notification)
    end

    it "redirects to the first step of the manual web form" do
      get :create
      expect(response).to redirect_to(get_manual_journey_url(assigns(:notification).id, "add_product_name"))
    end
  end

  describe "GET #show" do
    it "assigns the correct notification" do
      notification = Notification.create
      get(:show, params: { 'notification_id' => notification.id, 'id' => 'add_product_name' })
      expect(assigns(:notification)).to eq(notification)
    end

    it "renders the step template" do
      notification = Notification.create
      get(:show, params: { 'notification_id' => notification.id, 'id' => 'add_product_name' })
      expect(response).to render_template(:add_product_name)
    end
  end

  describe "POST #update" do
    it "assigns the correct notification" do
      notification = Notification.create
      post(:update, params: { 'notification_id' => notification.id, 'id' => 'add_product_name' })
      expect(assigns(:notification)).to eq(notification)
    end

    it "updates notification parameters if present" do
      notification = Notification.create
      post(:update,
          params: { 'notification_id' => notification.id, 
                    'id' => 'add_product_name', 
                    'notification' => { 'product_name' => 'Super Shampoo' } })
      expect(notification.reload.product_name).to eq('Super Shampoo')
    end

    it "marks the notification as complete on reaching the final step" do
      notification = Notification.create
      notification.aasm_state = 'draft_complete'
      notification.save
      post(:update, params: { 'notification_id' => notification.id, 'id' => 'check_your_answers' })
      expect(notification.reload.aasm_state).to eq('notification_complete')
    end
  end

  private

  def get_manual_journey_url(notificationId, step)
    "/notifications/%d/manual_entry/%s" % [notificationId, step]
  end
end
