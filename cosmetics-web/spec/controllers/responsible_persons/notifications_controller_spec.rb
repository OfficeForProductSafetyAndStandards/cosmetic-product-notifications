require 'rails_helper'

RSpec.describe ResponsiblePersons::NotificationsController, type: :controller do
  before do
    sign_in_test_user
  end

  after do
    sign_out_user
  end

  describe "GET #index" do
    it "assigns @responsible_person" do
      responsible_person = ResponsiblePerson.create
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:responsible_person)).to eq(responsible_person)
    end

    it "renders the index template" do
      responsible_person = ResponsiblePerson.create
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(response).to render_template('responsible_persons/notifications/index')
    end

    it "counts pending notification files" do
      responsible_person = ResponsiblePerson.create
      NotificationFile.create(responsible_person_id: responsible_person.id, user_id: controller.current_user.id)
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:pending_notification_files)).to eq(1)
    end
  end
end
