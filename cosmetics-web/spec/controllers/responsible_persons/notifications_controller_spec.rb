require 'rails_helper'

RSpec.describe ResponsiblePersons::NotificationsController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET #index" do
    it "assigns @responsible_person" do
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "renders the index template" do
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(response).to render_template('responsible_persons/notifications/index')
    end

    it "counts pending notification files" do
      NotificationFile.create(responsible_person_id: responsible_person.id, user_id: controller.current_user.id)
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:pending_notification_files_count)).to eq(1)
    end

    it "gets the correct number of unfinished notifications" do
      Notification.create(responsible_person_id: responsible_person.id, state: "draft_complete")
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:unfinished_notifications).count).to eq(1)
    end

    it "gets the correct number of registered notifications" do
      Notification.create(responsible_person_id: responsible_person.id, state: "notification_complete")
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:registered_notifications).count).to eq(1)
    end
  end
end
