require 'rails_helper'

RSpec.describe "Trigger questions", type: :request do
  include RSpecHtmlMatchers

  let!(:responsible_person) { create(:responsible_person) }
  let!(:notification) { create(:notification, responsible_person: responsible_person) }
  let(:component) { create(:predefined_component, notification: notification) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET #show" do
    context "when seeing the pH question" do
      before do
        get "/responsible_persons/#{responsible_person.id}/notifications/#{notification.id}/components/#{component.id}/trigger_question/select_ph_range"
      end

      it "renders the template" do
        expect(response).to render_template(:select_ph_range)
      end

      it "includes the question" do
        expect(response.body).to include('What is the pH range of the product?')
      end

      context "with a frame formulation component that has poisonous ingredients" do
        let(:component) { create(:predefined_component, notification: notification, contains_poisonous_ingredients: true) }

        it "includes a back link to the 'Upload poisonous ingredients' page" do
          expect(response.body).to have_tag("a.govuk-back-link", with: { href: "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/build/upload_formulation" })
        end
      end

      context "with a frame formulation component that does not have poisonous ingredients" do
        let(:component) { create(:predefined_component, notification: notification, contains_poisonous_ingredients: false) }

        it "includes a back link to the 'Poisonous ingredients' question" do
          expect(response.body).to have_tag("a.govuk-back-link", with: { href: "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/build/contains_poisonous_ingredients" })
        end
      end

      context "with an exact formulation component" do
        let(:component) { create(:exact_component, notification: notification) }

        it "includes a back link to the Upload formulation page" do
          expect(response.body).to have_tag("a.govuk-back-link", with: { href: "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/build/upload_formulation" })
        end
      end

      context "with a ranges formulation component" do
        let(:component) { create(:ranges_component, notification: notification) }

        it "includes a back link to the Upload formulation page" do
          expect(response.body).to have_tag("a.govuk-back-link", with: { href: "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/build/upload_formulation" })
        end
      end
    end

    context "with the exact pH question" do
      before do
        get "/responsible_persons/#{responsible_person.id}/notifications/#{notification.id}/components/#{component.id}/trigger_question/ph"
      end

      it "renders the template" do
        expect(response).to render_template(:ph)
      end

      it "includes the question" do
        expect(response.body).to include('What is the pH of the cosmetic product?')
      end

      it "includes a back link to the pH range question" do
        expect(response.body).to have_tag("a.govuk-back-link", with: { href: "/responsible_persons/#{responsible_person.id}/notifications/#{notification.id}/components/#{component.id}/trigger_question/select_ph_range" })
      end
    end
  end

  describe "PUT #update" do
    context "when answering the pH range question" do
      context "without specifying an answer" do
        before do
          put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.id}/components/#{component.id}/trigger_question/select_ph_range"
        end

        it "re-renders the page" do
          expect(response).to render_template(:select_ph_range)
        end

        it "displays an error message" do
          expect(response.body).to include("There is a problem")
        end
      end

      context "with 'it does not have a pH'" do
        before do
          put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.id}/components/#{component.id}/trigger_question/select_ph_range", params: { component: { ph: 'not_applicable' } }
        end

        it "sets the ph answer on the component" do
          expect(component.reload.ph).to eql('not_applicable')
        end

        context "when the notification was first notified pre-Brexit" do
          let(:notification) { create(:pre_eu_exit_notification, responsible_person: responsible_person, state: 'components_complete') }

          it "redirects to the add check your answers page" do
            expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit")
          end

          it "updates the notification state to draft_complete" do
            expect(notification.reload.state).to eql('draft_complete')
          end
        end

        context "when the notification was first notified post-Brexit" do
          it "redirects to the add product image page" do
            expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/build/add_product_image")
          end
        end
      end

      context "with 'The minimum pH is 3 or higher, and the maximum pH is 10 or lower'" do
        before do
          put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/trigger_question/select_ph_range", params: { component: { ph: 'between_3_and_10' } }
        end

        it "sets the ph answer on the component" do
          expect(component.reload.ph).to eql('between_3_and_10')
        end

        context "when the notification was first notified pre-Brexit" do
          let(:notification) { create(:pre_eu_exit_notification, responsible_person: responsible_person) }

          it "redirects to the add check your answers page" do
            expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit")
          end
        end

        context "when the notification was first notified post-Brexit" do
          it "redirects to the add product image page" do
            expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/build/add_product_image")
          end
        end
      end

      context "with 'The minimum pH is lower than 3'" do
        before do
          put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/trigger_question/select_ph_range", params: { component: { ph: 'lower_than_3' } }
        end

        it "sets the ph answer on the component" do
          expect(component.reload.ph).to eql('lower_than_3')
        end

        it "redirects to the exact pH question" do
          expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/trigger_question/ph")
        end
      end

      context "with 'The maximum pH is higher than 10'" do
        before do
          put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/trigger_question/select_ph_range", params: { component: { ph: 'above_10' } }
        end

        it "sets the ph answer on the component" do
          expect(component.reload.ph).to eql('above_10')
        end

        it "redirects to the exact pH question" do
          expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/components/#{component.id}/trigger_question/ph")
        end
      end
    end

    context "when answering the exact pH question" do
      context "without specifying an answer" do
        before do
          put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.id}/components/#{component.id}/trigger_question/ph"
        end

        it "re-renders the page" do
          expect(response).to render_template(:ph)
        end

        it "displays an error message" do
          expect(response.body).to include("There is a problem")
        end
      end

      context "when specifying a minimum and maximum pH" do
        before do
          put "/responsible_persons/#{responsible_person.id}/notifications/#{notification.id}/components/#{component.id}/trigger_question/ph", params: { component: { minimum_ph: '2.1 ', maximum_ph: '2.3 ' } }
        end

        it "sets the minimum ph value of the component" do
          expect(component.reload.minimum_ph).to be(2.1)
        end

        it "sets the maximum ph value of the component" do
          expect(component.reload.maximum_ph).to be(2.3)
        end

        context "when the notification was first notified pre-Brexit" do
          let(:notification) { create(:pre_eu_exit_notification, responsible_person: responsible_person, state: 'components_complete') }

          it "redirects to the add check your answers page" do
            expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/edit")
          end

          it "updates the notification state to draft_complete" do
            expect(notification.reload.state).to eql('draft_complete')
          end
        end

        context "when the notification was first notified post-Brexit" do
          it "redirects to the add product image page" do
            expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications/#{notification.reference_number}/build/add_product_image")
          end
        end
      end
    end
  end
end
