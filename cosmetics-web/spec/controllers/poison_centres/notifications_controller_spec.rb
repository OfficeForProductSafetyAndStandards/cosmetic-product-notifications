require 'rails_helper'

RSpec.describe PoisonCentres::NotificationsController, type: :controller do
  let(:responsible_person_1) { create(:responsible_person, email_address: "one@example.com") }
  let(:responsible_person_2) { create(:responsible_person, email_address: "two@example.com") }

  let(:rp_1_notifications) { create_list(:registered_notification, 3, responsible_person: responsible_person_1) }
  let(:rp_2_notifications) { create_list(:registered_notification, 3, responsible_person: responsible_person_2) }

  after do
    sign_out
  end

  describe "When signed in as a Poison Centre user" do
    before do
      sign_in_as_poison_centre_user
    end

    describe "GET #index" do
      it "gets all registered notifications" do
        get :index
        expect(assigns(:notifications)).to eq(rp_1_notifications + rp_2_notifications)
      end

      it "excludes draft notifications" do
        draft_notification = create(:draft_notification, responsible_person: responsible_person_1)
        get :index
        expect(assigns(:notifications)).not_to include(draft_notification)
      end

      it "excludes unfinished imported notifications" do
        imported_notification = create(:imported_notification, responsible_person: responsible_person_1)
        get :index
        expect(assigns(:notifications)).not_to include(imported_notification)
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template("notifications/index")
      end
    end

    describe "GET #show" do
      let(:notification) { rp_1_notifications.first }

      it "assigns the correct notification" do
        get :show, params: { reference_number: notification.reference_number }
        expect(assigns(:notification)).to eq(notification)
      end

      it "renders the show template" do
        get :show, params: { reference_number: notification.reference_number }
        expect(response).to render_template("notifications/show")
      end
    end
  end

  describe "When signed in as a Responsible Person user" do
    before do
      sign_in_as_member_of_responsible_person(responsible_person_1)
    end

    describe "GET #index" do
      it "raises NotAuthorizedError" do
        expect {
          get :index
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    describe "GET #show" do
      it "raises NotAuthorizedError" do
        expect {
          get :show, params: { reference_number: rp_1_notifications.first.reference_number }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
