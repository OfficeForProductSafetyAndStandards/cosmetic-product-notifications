require 'rails_helper'

RSpec.describe TriggerQuestionsController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }
  let(:component) { create(:component, notification_type: component_type, contains_poisonous_ingredients: contains_poisonous_ingredients) }
  let(:notification) { create(:notification, components: [component], responsible_person: responsible_person) }
  let(:multi_component_notification) { create(:notification, components: [create(:component), create(:component)], responsible_person: responsible_person) }
  let(:component_type) { nil }
  let(:contains_poisonous_ingredients) { nil }

  let(:params) {
    {
        responsible_person_id: responsible_person.id,
        notification_reference_number: notification.reference_number,
        component_id: component.id
    }
  }

  let(:multi_component_params) {
    {
        responsible_person_id: responsible_person.id,
        notification_reference_number: notification.reference_number,
        component_id: multi_component_notification.components.first.id
    }
  }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "GET #new" do
    it "redirects to the first step of the wizard" do
      get(:new, params: params)
      expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, notification, component, :contains_anti_dandruff_agents))
    end
  end

  describe "GET #show" do
    it "assigns the correct component" do
      get(:show, params: params.merge(id: :contains_anti_dandruff_agents))
      expect(assigns(:component)).to eq(component)
    end

    it "renders the step template" do
      get(:show, params: params.merge(id: :contains_anti_dandruff_agents))
      expect(response).to render_template(:contains_anti_dandruff_agents)
    end

    it "redirects to the add product image page on finish, when the notification contains only one component" do
      get(:show, params: params.merge(id: :wicked_finish))
      expect(response).to redirect_to(responsible_person_notification_build_path(responsible_person, notification, :add_product_image))
    end

    it "redirects to the add new component page on finish, when the notification contains only one component" do
      get(:show, params: multi_component_params.merge(id: :wicked_finish))
      expect(response).to redirect_to(responsible_person_notification_build_path(responsible_person, multi_component_notification, :add_new_component))
    end

    it "initialises question with the right value in contains_anti_dandruff_agents step" do
      get(:show, params: params.merge(id: :contains_anti_dandruff_agents))
      expect(assigns(:question).question).to eq("please_specify_the_inci_name_and_concentration_of_the_antidandruff_agents_if_antidandruff_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked")
      expect(assigns(:question).applicable).to eq(nil)
    end

    it "initialises 20 empty answers in add_anti_dandruff_agents step" do
      get(:show, params: params.merge(id: :add_anti_dandruff_agents))
      expect(assigns(:question).trigger_question_elements).to have(20).items
      expect(assigns(:question).trigger_question_elements).to all(have_attributes(answer: be_nil))
    end

    describe "back link" do
      render_views

      context "when on the first step page" do
        before { get(:show, params: params.merge(id: :contains_anti_dandruff_agents)) }

        context "when the component is of predefined formulation" do
          let(:component_type) { "predefined" }

          context "when the component contains poisonous ingredients" do
            let(:contains_poisonous_ingredients) { true }

            it "links to the upload formulation page" do
              expect(response.body).to match(/\<a class="govuk-back-link" href=".+\/build\/upload_formulation">Back<\/a>/)
            end
          end

          context "when the component does not contain poisonous ingredients" do
            let(:contains_poisonous_ingredients) { false }

            it "links to the poisonous materials page" do
              expect(response.body).to match(/\<a class="govuk-back-link" href=".+\/build\/contains_poisonous_ingredients">Back<\/a>/)
            end
          end
        end

        context "when the component is not of predefined formulation" do
          let(:component_type) { "exact" }

          it "links to the upload formulation page" do
            expect(response.body).to match(/\<a class="govuk-back-link" href=".+\/build\/upload_formulation">Back<\/a>/)
          end
        end
      end
    end
  end

  describe "POST #update" do
    it "assigns the applicable to true if selected as true in a check question" do
      post(:update, params: params.merge(id: :contains_anti_dandruff_agents, trigger_question: { applicable: 'true' }))
      expect(assigns(:question).applicable).to eq(true)
    end

    it "assigns the applicable to false if selected as false in a check question" do
      post(:update, params: params.merge(id: :contains_anti_dandruff_agents, trigger_question: { applicable: 'false' }))
      expect(assigns(:question).applicable).to eq(false)
    end

    it "proceeds to add_anti_dandruff_agents step if user selects as applicable before" do
      post(:update, params: params.merge(id: :contains_anti_dandruff_agents, trigger_question: { applicable: 'true' }))
      expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, notification, component, :add_anti_dandruff_agents))
    end

    it "skips add_anti_dandruff_agents step if user selects as not applicable before" do
      post(:update, params: params.merge(id: :contains_anti_dandruff_agents, trigger_question: { applicable: 'false' }))
      expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, notification, component, :select_ph_range))
    end

    context "when setting the pH answer" do
      context "when the answer is 'It does not have a pH'" do
        before do
          post(:update, params: params.merge(id: :select_ph_range, component: { ph: 'not_applicable' }))
        end

        it "redirects to the hair-loss agents question" do
          expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, notification, component, :contains_anti_hair_loss_agents))
        end
      end

      context "when the answer is between 3 and 10" do
        before do
          post(:update, params: params.merge(id: :select_ph_range, component: { ph: 'between_3_and_10' }))
        end

        it "redirects to the hair-loss agents question" do
          expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, notification, component, :contains_anti_hair_loss_agents))
        end
      end

      context "when the answer is lower than 3" do
        before do
          post(:update, params: params.merge(id: :select_ph_range, component: { ph: 'lower_than_3' }))
        end

        it "redirects to the pH range question" do
          expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, notification, component, :ph))
        end
      end

      context "when the answer is higher than 10" do
        before do
          post(:update, params: params.merge(id: :select_ph_range, component: { ph: 'lower_than_3' }))
        end

        it "redirects to the pH range question" do
          expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, notification, component, :ph))
        end
      end

      context "when no answer is selected" do
        before do
          post(:update, params: params.merge(id: :select_ph_range, component: { ph: nil }))
        end

        it "re-renders the page" do
          expect(response.status).to be(200)
        end
      end
    end

    context "when setting the pH range" do
      let!(:alkaline_agent_trigger_question) { create(:trigger_question, component: component, question: 'please_indicate_the_inci_name_and_concentration_of_each_alkaline_agent_including_ammonium_hydroxide_liberators') }
      let!(:alkaline_agent_trigger_question_element) { create(:trigger_question_element, trigger_question: alkaline_agent_trigger_question) }

      context "when the maximum is above 10" do
        before do
          post(:update, params: params.merge(id: :ph, component: { minimum_ph: 10, maximum_ph: 11 }))
        end

        it "redirects to the alkaline question" do
          expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, notification, component, :add_alkaline_agents))
        end

        it "sets the alkaline trigger question to be applicable" do
          expect(alkaline_agent_trigger_question.reload.applicable).to be true
        end
      end

      context "when the maximum is below 10" do
        before do
          post(:update, params: params.merge(id: :ph, component: { minimum_ph: 8, maximum_ph: 8.2 }))
        end

        it "redirects to the hair-loss agents question" do
          expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, notification, component, :contains_anti_hair_loss_agents))
        end

        it "deletes the trigger question element" do
          expect { alkaline_agent_trigger_question_element.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable RSpec/MultipleExpectations
    describe "at add_anti_dandruff_agents step" do
      let(:question) {
        create(:trigger_question, component: component,
               question: "please_specify_the_inci_name_and_concentration_of_the_antidandruff_agents_if_antidandruff_agents_are_not_present_in_the_cosmetic_product_then_not_applicable_must_be_checked",
               applicable: false)
      }
      let(:answers) {
        [
            create(:trigger_question_element, trigger_question: question, answer_order: 0, element_order: 0),
            create(:trigger_question_element, trigger_question: question, answer_order: 0, element_order: 1),
            create(:trigger_question_element, trigger_question: question, answer_order: 1, element_order: 0),
            create(:trigger_question_element, trigger_question: question, answer_order: 1, element_order: 1)
        ]
      }

      let(:valid_answers) {
        [
            { answer: "agent 1", answer_order: 0, element_order: 0, element: :inciname, id: answers.first.id },
            { answer: "5", answer_order: 0, element_order: 0, element: :incivalue, id: answers.second.id }
        ]
      }

      let(:valid_answers_with_empty_values) {
        [
            { answer: "agent 1", answer_order: 0, element_order: 0, element: "inciname", id: answers.first.id },
            { answer: "5", answer_order: 0, element_order: 1, element: "incivalue", id: answers.second.id },
            { answer: "", answer_order: 1, element_order: 0, element: "inciname", id: answers.third.id },
            { answer: "", answer_order: 1, element_order: 1, element: "incivalue", id: answers.fourth.id }
        ]
      }

      let(:valid_answers_with_unpaired_values) {
        [
            { answer: "agent 1", answer_order: 0, element_order: 0, element: "inciname", id: answers.first.id },
            { answer: "5", answer_order: 0, element_order: 0, element: "incivalue", id: answers.second.id },
            { answer: "agent 2", answer_order: 1, element_order: 0, element: "inciname", id: answers.third.id },
            { answer: "", answer_order: 1, element_order: 1, element: "incivalue", id: answers.fourth.id }
        ]
      }

      let(:invalid_answers) { [{ answer: "", answer_order: 0, element_order: 0, element: "inciname", id: answers.first.id }] }

      it "add filled answers to trigger_question_elements" do
        post(:update, params: params.merge(id: :add_anti_dandruff_agents, trigger_question: {
            trigger_question_elements_attributes: valid_answers
        }))
        expect(assigns(:question).trigger_question_elements).to have(2).items
        expect(assigns(:question).trigger_question_elements.first.answer).to eq("agent 1")
        expect(assigns(:question).trigger_question_elements.second.answer).to eq("5")
      end

      it "ignore empty answers" do
        post(:update, params: params.merge(id: :add_anti_dandruff_agents, trigger_question: {
            trigger_question_elements_attributes: valid_answers_with_empty_values
        }))
        expect(assigns(:question).trigger_question_elements).to have(2).items
        expect(assigns(:question).trigger_question_elements.first.answer).to eq("agent 1")
        expect(assigns(:question).trigger_question_elements.second.answer).to eq("5")
      end

      it "set errors when there is unpaired answers" do
        post(:update, params: params.merge(id: :add_anti_dandruff_agents, trigger_question: {
            trigger_question_elements_attributes: valid_answers_with_unpaired_values
        }))
        expect(assigns(:question).errors).not_to be_nil
      end

      it "sets question as applicable when succeed to add answers" do
        post(:update, params: params.merge(id: :add_anti_dandruff_agents, trigger_question: {
            trigger_question_elements_attributes: valid_answers
        }))
        expect(assigns(:question).applicable).to eq(true)
      end

      it "does not set errors when succeed to update an answer" do
        post(:update, params: params.merge(id: :add_anti_dandruff_agents, trigger_question: {
            trigger_question_elements_attributes: valid_answers
        }))
        expect(assigns(:question).errors.messages).to be_empty
      end

      it "set errors when fails to update" do
        post(:update, params: params.merge(id: :add_anti_dandruff_agents, trigger_question: {
            trigger_question_elements_attributes: invalid_answers
        }))
        expect(assigns(:question).errors.messages).not_to be_empty
      end

      it "re initialize 20 empty answers when it fails to update" do
        post(:update, params: params.merge(id: :add_anti_dandruff_agents, trigger_question: {
            trigger_question_elements_attributes: invalid_answers
        }))
        expect(assigns(:question).trigger_question_elements).to have(20).items
        expect(assigns(:question).trigger_question_elements).to all(have_attributes(answer: be_nil))
      end
    end
    # rubocop:enable RSpec/MultipleExpectations
    # rubocop:enable RSpec/ExampleLength
  end
end
