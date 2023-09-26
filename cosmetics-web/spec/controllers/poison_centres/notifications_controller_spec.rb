require "rails_helper"

RSpec.describe PoisonCentres::NotificationsController, type: :controller do
  subject(:load_page) do
    get :show, params: { reference_number: }
  end

  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let!(:notification) { create(:registered_notification, :with_nano_materials, responsible_person:) }
  let(:archived_notification) { create(:archived_notification, responsible_person:) }
  let(:reference_number) { notification.reference_number }

  before do
    create(:component, :with_exact_ingredients, notification:, sub_sub_category: "nonoxidative_hair_colour_products")
  end

  after do
    sign_out(:search_user)
  end

  describe "When signed in as a Poison Centre user" do
    before do
      sign_in_as_poison_centre_user
      load_page
    end

    describe "GET #show" do
      it "decorates the correct notification" do
        expect(assigns(:notification).id).to eq(notification.id)
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
      load_page
    end

    describe "GET #show" do
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
      load_page
    end

    describe "GET #show" do
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
      load_page
    end

    describe "GET #show" do
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
      load_page
    end

    describe "GET #show" do
      it "renders the show detail template" do
        expect(response).to render_template("notifications/show_detail")
      end

      describe "displayed information" do
        let(:component) { create(:component, :with_poisonous_ingredients, :with_trigger_questions) }
        let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
        let(:notification) { create(:notification, :registered, :ph_values, components: [component], responsible_person:) }

        render_views

        it_behaves_like "a notification search result with contact person overview"
        it_behaves_like "a notification search result with ingredients but without exact percentages"
        it_behaves_like "a notification search result with general component technical details"
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
        expect(get(:show, params: { reference_number: notification.reference_number })).to redirect_to("/invalid-account")
      end
    end
  end
end
