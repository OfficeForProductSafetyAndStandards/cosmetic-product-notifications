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
      expect(assigns(:pending_notification_files)).to eq(1)
    end
  end
end
