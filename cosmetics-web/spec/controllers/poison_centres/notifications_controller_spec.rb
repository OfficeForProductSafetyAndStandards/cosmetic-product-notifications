require "rails_helper"

RSpec.describe PoisonCentres::NotificationsController, type: :controller do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:notifications) { create_list(:registered_notification, 3, :with_components, :with_nano_materials, responsible_person:) }
  let(:archived_notification) { create(:archived_notification, responsible_person:) }

  after do
    sign_out(:search_user)
  end

  describe "When signed in as a Poison Centre user" do
    before do
      sign_in_as_poison_centre_user
    end

    describe "GET #show" do
      let(:notification) { notifications.first }
      let(:reference_number) { notification.reference_number }

      before { get :show, params: { reference_number: } }

      it "assigns the correct notification" do
        expect(assigns(:notification)).to eq(notification)
      end

      it "renders the show detail template" do
        expect(response).to render_template("notifications/show_detail")
      end

      describe "displayed information for archived notifications", versioning: true do
        let(:reference_number) { archived_notification.reference_number }

        render_views

        it "does not render the archive history" do
          expect(response.body).not_to match(/Archive history/)
        end
      end

      context "when the notification is not found" do
        let(:reference_number) { "1234wrongreference" }

        it "redirects to 404 page" do
          expect(response).to redirect_to("/404")
        end
      end
    end
  end

  describe "When signed in as an OPSS General user" do
    before do
      sign_in_as_opss_general_user
    end

    describe "GET #show" do
      let(:notification) { notifications.first }
      let(:reference_number) { notification.reference_number }

      before { get :show, params: { reference_number: } }

      it "renders the show template" do
        expect(response).to render_template("notifications/show")
      end

      describe "displayed information" do
        let(:component) { create(:component, :with_poisonous_ingredients, :with_trigger_questions) }
        let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
        let(:notification) { create(:notification, :registered, :ph_values, components: [component], responsible_person:) }

        render_views

        it_behaves_like "a notification search result with contact person overview"
        it_behaves_like "a notification search result without ingredients"
        it_behaves_like "a notification search result without any component technical details"
      end

      describe "displayed information for archived notifications", versioning: true do
        let(:reference_number) { archived_notification.reference_number }

        render_views

        it "does not render the archive history" do
          expect(response.body).not_to match(/Archive history/)
        end
      end
    end
  end

  describe "When signed in as an OPSS Enforcement user" do
    before do
      sign_in_as_opss_enforcement_user
    end

    describe "GET #show" do
      let(:notification) { notifications.first }
      let(:reference_number) { notification.reference_number }

      before { get :show, params: { reference_number: } }

      it "renders the show detail template" do
        expect(response).to render_template("notifications/show_detail")
      end

      describe "displayed information" do
        let(:component) { create(:component, :with_poisonous_ingredients, :with_trigger_questions) }
        let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
        let(:notification) { create(:notification, :registered, :ph_values, components: [component], responsible_person:) }

        render_views

        it_behaves_like "a notification search result with contact person overview"
        it_behaves_like "a notification search result with general component technical details"
        it_behaves_like "a notification search result with ingredients and their exact percentages"
      end

      describe "displayed information for archived notifications", versioning: true do
        let(:reference_number) { archived_notification.reference_number }

        render_views

        it "renders the history" do
          expect(response.body).to match(/History/)
        end
      end
    end
  end

  describe "When signed in as an OPSS IMT user" do
    before do
      sign_in_as_opss_imt_user
    end

    describe "GET #show" do
      let(:notification) { notifications.first }
      let(:reference_number) { notification.reference_number }

      before { get :show, params: { reference_number: } }

      it "renders the show detail template" do
        expect(response).to render_template("notifications/show_detail")
      end

      describe "displayed information" do
        let(:component) { create(:component, :with_poisonous_ingredients, :with_trigger_questions) }
        let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
        let(:notification) { create(:notification, :registered, :ph_values, components: [component], responsible_person:) }

        render_views

        it_behaves_like "a notification search result with contact person overview"
        it_behaves_like "a notification search result with general component technical details"
        it_behaves_like "a notification search result with ingredients and their exact percentages"
      end

      describe "displayed information for archived notifications", versioning: true do
        let(:reference_number) { archived_notification.reference_number }

        render_views

        it "renders the history" do
          expect(response.body).to match(/History/)
        end
      end
    end
  end

  describe "When signed in as an Trading Standards user" do
    before do
      sign_in_as_trading_standards_user
    end

    describe "GET #show" do
      let(:notification) { notifications.first }
      let(:reference_number) { notification.reference_number }

      before { get :show, params: { reference_number: } }

      it "renders the show detail template" do
        expect(response).to render_template("notifications/show_detail")
      end

      describe "displayed information" do
        let(:component) { create(:component, :with_poisonous_ingredients, :with_trigger_questions) }
        let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
        let(:notification) { create(:notification, :registered, :ph_values, components: [component], responsible_person:) }

        render_views

        it "renders contact person overview" do
          expect(response.body).to match(/Assigned contact/)
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

        it "does not render maximum pH" do
          expect(response.body).not_to match(/Maximum pH value/)
        end

        it "does not render still on the market" do
          expect(response.body).not_to match(/Still on the market/)
        end

        it "renders nanomaterials" do
          expect(response.body).to match(/Nanomaterials/)
        end

        it "renders physical form" do
          expect(response.body).to match(/Physical form/)
        end
      end

      describe "displayed information for archived notifications", versioning: true do
        let(:reference_number) { archived_notification.reference_number }

        render_views

        it "renders the history" do
          expect(response.body).to match(/History/)
        end
      end
    end
  end

  describe "When signed in as a Responsible Person user" do
    before do
      sign_in_as_member_of_responsible_person(responsible_person)
    end

    describe "GET #show" do
      it "redirects to invalid account" do
        expect(get(:show, params: { reference_number: notifications.first.reference_number })).to redirect_to("/invalid-account")
      end
    end
  end
end
