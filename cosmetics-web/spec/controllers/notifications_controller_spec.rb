require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  before do
    sign_in
  end

  after do
    sign_out
  end

  describe "GET /confimation" do
    it "assigns the correct notification" do
      notification = Notification.create
      get(:confirmation, params: { id: notification.id })
      expect(assigns(:notification)).to eq(notification)
    end

    it "marks the notification as complete" do
      notification = Notification.create
      notification.state = 'draft_complete'
      notification.save
      get(:confirmation, params: { id: notification.id })
      expect(notification.reload.state).to eq('notification_complete')
    end
  end

  describe "GET /edit" do
    it "assigns the correct notification" do
      notification = Notification.create
      get(:edit, params: { id: notification.id })
      expect(assigns(:notification)).to eq(notification)
    end
  end
end
