require "rails_helper"

RSpec.describe PoisonCentres::NotificationsController, type: :controller do
  let(:responsible_person_1) { create(:responsible_person, :with_a_contact_person) }
  let(:responsible_person_2) { create(:responsible_person, :with_a_contact_person) }

  let(:rp_1_notifications) { create_list(:registered_notification, 3, responsible_person: responsible_person_1) }
  let(:rp_2_notifications) { create_list(:registered_notification, 3, responsible_person: responsible_person_2) }

  let(:draft_notification) { create(:draft_notification, responsible_person: responsible_person_1) }
  let(:imported_notification) { create(:imported_notification, responsible_person: responsible_person_1) }

  let(:distinct_notification) { create(:registered_notification, responsible_person: responsible_person_1, product_name: "bbbb") }
  let(:similar_notification_one) { create(:registered_notification, responsible_person: responsible_person_1, product_name: "aaaa") }
  let(:similar_notification_two) { create(:registered_notification, responsible_person: responsible_person_1, product_name: "aaab") }

  after do
    sign_out(:search_user)
  end

  describe "When signed in as a Poison Centre user" do
    before do
      sign_in_as_poison_centre_user
    end

    describe "GET #index" do
      before do
        rp_1_notifications
        rp_2_notifications
        draft_notification
        imported_notification
        Notification.elasticsearch.import force: true
        get :index
      end

      it "gets all submitted notifications" do
        expect(assigns(:notifications).records.to_a.sort).to eq((rp_1_notifications + rp_2_notifications).sort)
      end

      it "excludes draft notifications" do
        expect(assigns(:notifications).records.to_a).not_to include(draft_notification)
      end

      it "excludes incomplete imported notifications" do
        expect(assigns(:notifications).records.to_a).not_to include(imported_notification)
      end

      it "renders the index template" do
        expect(response).to render_template("notifications/index")
      end
    end

    describe "search on #index" do
      before do
        distinct_notification
        similar_notification_one
        similar_notification_two
        Notification.elasticsearch.import force: true
      end

      it "finds the correct notification" do
        get :index, params: { q: "bbbb" }
        expect(assigns(:notifications).records.to_a).to eq([distinct_notification])
      end

      it "finds similar notifications with fuzzy search" do
        get :index, params: { q: "aaaa" }
        expect(assigns(:notifications).records.to_a.sort).to eq([similar_notification_one, similar_notification_two].sort)
      end
    end

    describe "GET #show" do
      let(:notification) { rp_1_notifications.first }

      before { get :show, params: { reference_number: notification.reference_number } }

      it "assigns the correct notification" do
        expect(assigns(:notification)).to eq(notification)
      end

      it "renders the show template" do
        expect(response).to render_template("notifications/show_poison_centre")
      end
    end
  end

  describe "When signed in as an MSA user" do
    before do
      sign_in_as_msa_user
    end

    describe "GET #index" do
      it "renders the index template" do
        get :index
        expect(response).to render_template("notifications/index")
      end
    end

    describe "GET #show" do
      let(:notification) { rp_1_notifications.first }

      before { get :show, params: { reference_number: notification.reference_number } }

      it "renders the show template" do
        expect(response).to render_template("notifications/show_msa")
      end

      describe "displayed information" do
        let(:component) { create(:component, :with_poisonous_ingredients, :with_trigger_questions) }
        let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
        let(:notification) { create(:notification, :imported, :registered, :ph_values, components: [component], responsible_person: responsible_person) }

        render_views

        it "renders contact person overview" do
          expect(response.body).to match(/Contact person/)
        end

        it "does not render product imported status" do
          expect(response.body).not_to match(/Imported/)
        end

        it "does not render component formulations" do
          expect(response.body).not_to match(/Formulation given as/)
          expect(response.body).not_to match(/Frame formulation/)
        end

        it "does not render acute poisoning info" do
          expect(response.body).not_to match(/Acute poisoning information/)
        end

        it "does not render poisonous ingredients" do
          expect(response.body).not_to match(/Contains poisonous ingredients/)
        end

        it "does not render trigger questions" do
          expect(response.body).not_to match(/<tr class="govuk-table__row trigger-question">/)
        end

        it "does not render minimum pH" do
          expect(response.body).not_to match(/Minimum pH value/)
        end

        it "does not render Maximum pH" do
          expect(response.body).not_to match(/Maximum pH value/)
        end

        it "does not render still on the market" do
          expect(response.body).not_to match(/Still on the market/)
        end

        it "renders CMR substances" do
          expect(response.body).to match(/Contains CMR substances/)
        end

        it "renders nanomaterials" do
          expect(response.body).to match(/Nanomaterials/)
        end

        it "renders physical form" do
          expect(response.body).to match(/Physical form/)
        end
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
