require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  before do
    sign_in_as_member_of_responsible_person(create(:responsible_person))
  end

  after do
    sign_out
  end

  describe "GET /confirmation" do
    it "assigns the correct notification" do
      notification = create(:notification)
      get(:confirmation, params: { id: notification.id })
      expect(assigns(:notification)).to eq(notification)
    end

    it "marks the notification as complete" do
      notification = create(:draft_notification)
      get(:confirmation, params: { id: notification.id })
      expect(notification.reload.state).to eq('notification_complete')
    end
  end

  describe "GET /edit" do
    it "assigns the correct notification" do
      notification = create(:notification)
      get(:edit, params: { id: notification.id })
      expect(assigns(:notification)).to eq(notification)
    end
  end

  describe "GET /new" do
    it "creates new notification object" do
      get :new
      expect(assigns(:notification)).to be_kind_of(Notification)
    end

    it "redirects to the notification build controller" do
      get :new
      expect(response).to redirect_to(new_notification_build_path(assigns(:notification).id))
    end
  end
end
