require "rails_helper"

RSpec.describe ResponsiblePersons::DraftNotificationsController, :with_stubbed_antivirus, type: :controller do
  let(:user) { build(:submit_user) }
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:predefined_component) { create(:component) }
  let(:ranges_component) { create(:ranges_component) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person, user)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET #index" do
    it "renders the index template" do
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(response).to render_template("responsible_persons/draft_notifications/index")
    end

    it "gets the correct number of unfinished notifications" do
      create(:draft_notification, responsible_person:)
      get :index, params: { responsible_person_id: responsible_person.id }
      expect(assigns(:unfinished_notifications).count).to eq(1)
    end
  end
end
