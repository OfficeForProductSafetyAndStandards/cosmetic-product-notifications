require "rails_helper"

RSpec.describe PoisonCentres::NotificationsSearchController, type: :controller do
  let(:responsible_person_a) { create(:responsible_person, :with_a_contact_person) }
  let(:responsible_person_b) { create(:responsible_person, :with_a_contact_person) }

  let(:rp_a_notifications) { create_list(:registered_notification, 3, responsible_person: responsible_person_a) }
  let(:rp_b_notifications) { create_list(:registered_notification, 3, responsible_person: responsible_person_b) }

  let(:draft_notification) { create(:draft_notification, responsible_person: responsible_person_a) }

  let(:distinct_notification) { create(:registered_notification, responsible_person: responsible_person_a, product_name: "bbbb") }
  let(:similar_notification_one) { create(:registered_notification, responsible_person: responsible_person_a, product_name: "aaaa") }
  let(:similar_notification_two) { create(:registered_notification, responsible_person: responsible_person_a, product_name: "aaab") }

  after do
    sign_out(:search_user)
  end

  describe "When signed in as a Poison Centre user" do
    before do
      sign_in_as_poison_centre_user
    end

    describe "GET #show" do
      before do
        rp_a_notifications
        rp_b_notifications
        draft_notification
        Notification.import_to_opensearch(force: true)
        get :show, params: { notification_search_form: { q: "" } }
      end

      it "gets all submitted notifications" do
        expect(assigns(:notifications).records.to_a.sort).to eq((rp_a_notifications + rp_b_notifications).sort)
      end

      it "excludes draft notifications" do
        expect(assigns(:notifications).records.to_a).not_to include(draft_notification)
      end

      it "renders the show template" do
        expect(response).to render_template("notifications_search/show")
      end
    end

    describe "search on #show" do
      before do
        distinct_notification
        similar_notification_one
        similar_notification_two
        Notification.import_to_opensearch(force: true)
      end

      it "finds the correct notification" do
        get :show, params: { notification_search_form: { q: "bbbb" } }
        expect(assigns(:notifications).records.to_a).to eq([distinct_notification])
      end
    end
  end

  describe "When signed in as an OPSS General user" do
    before do
      sign_in_as_opss_general_user
    end

    describe "GET #show" do
      it "renders the show template" do
        get :show
        expect(response).to render_template("notifications_search/show")
      end
    end
  end

  describe "When signed in as an OPSS Enforcement user" do
    before do
      sign_in_as_opss_enforcement_user
    end

    describe "GET #show" do
      it "renders the show template" do
        get :show
        expect(response).to render_template("notifications_search/show")
      end
    end
  end

  describe "When signed in as an OPSS IMT user" do
    before do
      sign_in_as_opss_imt_user
    end

    describe "GET #show" do
      it "renders the show template" do
        get :show
        expect(response).to render_template("notifications_search/show")
      end
    end
  end

  describe "When signed in as a Trading Standards user" do
    before do
      sign_in_as_trading_standards_user
    end

    describe "GET #show" do
      it "renders the show template" do
        get :show
        expect(response).to render_template("notifications_search/show")
      end
    end
  end

  describe "When signed in as a Responsible Person user" do
    before do
      sign_in_as_member_of_responsible_person(responsible_person_a)
    end

    describe "GET #show" do
      it "redirects to invalid account" do
        expect(get(:show)).to redirect_to("/invalid-account")
      end
    end
  end
end
