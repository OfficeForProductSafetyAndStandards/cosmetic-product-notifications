require "rails_helper"

RSpec.describe ComponentBuildController, type: :controller do
  let(:responsible_person) { create(:responsible_person) }
  let(:component) { create(:component, notification_type: component_type) }
  let(:notification) { create(:notification, components: [component], responsible_person: responsible_person) }
  let(:pre_eu_exit_notification) { create(:notification, :pre_brexit, components: [component], responsible_person: responsible_person) }
  let(:component_type) { nil }

  let(:params) {
    {
      responsible_person_id: responsible_person.id,
      notification_reference_number: notification.reference_number,
      component_id: component.id,
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
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :number_of_shades))
    end

    it "does not allow the user to create a notification component for a Responsible Person they not belong to" do
      expect {
        get(:new, params: other_responsible_person_params)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "GET #show" do
    it "assigns the correct notification" do
      get(:show, params: params.merge(id: :number_of_shades))
      expect(assigns(:component)).to eq(component)
    end

    it "renders the step template" do
      get(:show, params: params.merge(id: :number_of_shades))
      expect(response).to render_template(:number_of_shades)
    end

    it "redirects to the trigger rules page on finish" do
      get(:show, params: params.merge(id: :wicked_finish))
      expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, notification, component, :select_ph_range))
    end

    it "initialises shades array with two empty strings in add_shades step" do
      get(:show, params: params.merge(id: :add_shades))
      expect(assigns(:component).shades).to eq(["", ""])
    end

    it "does not allow the user to view a notification component for a Responsible Person they not belong to" do
      expect {
        get(:show, params: other_responsible_person_params.merge(id: :number_of_shades))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "does not allow the user to update a notification component that has already been submitted" do
      notification.update state: "notification_complete"
      expect {
        get(:show, params: params.merge(id: :number_of_shades))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "initialises 5 empty cmrs in add_cmrs step" do
      get(:show, params: params.merge(id: :add_cmrs))
      expect(assigns(:component).cmrs).to have(5).items
      expect(assigns(:component).cmrs).to all(have_attributes(name: be_nil))
    end

    describe "upload product ingredients page" do
      before { get(:show, params: params.merge(id: :upload_formulation)) }

      render_views

      describe "page title" do
        context "with a component with predefined formulation" do
          let(:component_type) { "predefined" }

          it "sets the page title to poisonous ingredients" do
            expect(response.body).to match(/<title>Upload list of poisonous ingredients .+<\/title>/)
          end
        end

        context "with a component without predefined formulation" do
          let(:component_type) { "exact" }

          it "sets the page title to product ingredients" do
            expect(response.body).to match(/<title>Upload list of ingredients .+<\/title>/)
          end
        end
      end

      describe "back link" do
        context "with a component with predefined formulation" do
          let(:component_type) { "predefined" }

          it "links to the poisonous materials page" do
            path = responsible_person_notification_component_build_path(responsible_person, notification, component, :contains_poisonous_ingredients)
            expect(response.body).to match(/\<a class="govuk-back-link" href="#{path}">Back<\/a>/)
          end
        end

        context "with a component without predefined formulation" do
          let(:component_type) { "exact" }

          it "links to the select formulation type page" do
            path = responsible_person_notification_component_build_path(responsible_person, notification, component, :select_formulation_type)
            expect(response.body).to match(/\<a class="govuk-back-link" href="#{path}">Back<\/a>/)
          end
        end
      end
    end
  end

  describe "POST #update" do
    it "assigns the correct notification" do
      post(:update, params: params.merge(id: :number_of_shades, component: { shades: [] }))
      expect(assigns(:component)).to eq(component)
    end

    it "updates notification parameters if present" do
      post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue] }))
      expect(component.reload.shades).to eq(%w[red blue])
    end

    it "proceeds to add_shades step if user wants to add shades" do
      post(:update, params: params.merge(id: :number_of_shades, component: { number_of_shades: "multiple-shades-same-notification" }))
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :add_shades))
    end

    it "skips add_shades step if user chooses to submit separate notifications for each shade" do
      post(:update, params: params.merge(id: :number_of_shades, component: { number_of_shades: "multiple-shades-different-notification" }))
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :add_physical_form))
    end

    it "skips add_shades step if product has single or no shades" do
      post(:update, params: params.merge(id: :number_of_shades, component: { number_of_shades: "single-or-no-shades" }))
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :add_physical_form))
    end

    it "adds errors if number_of_shades is empty" do
      post(:update, params: params.merge(id: :number_of_shades, component: { number_of_shades: nil }))
      expect(assigns(:component).errors[:number_of_shades]).to eql(["Select yes if the product is available in different shades"])
    end

    it "adds empty string to shades array if add_shade parameter passed" do
      post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue] }, add_shade: true))
      expect(assigns(:component).shades).to eq(["red", "blue", ""])
    end

    it "removes shade from list if passed remove_shade_with_id" do
      post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue yellow] }, remove_shade_with_id: 1))
      expect(assigns(:component).shades).to eq(%w[red yellow])
    end

    it "adds an empty string to shades if removing an element would leave less than two" do
      post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue] }, remove_shade_with_id: 0))
      expect(assigns(:component).shades).to eq(["blue", ""])
    end

    it "does not allow the user to update a notification component for a Responsible Person they not belong to" do
      expect {
        post(:update, params: other_responsible_person_params.merge(id: :add_shades, component: { shades: %w[red blue] }))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "does not allow the user to update a notification that has already been submitted" do
      notification.update state: "notification_complete"
      expect {
        post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue] }))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "proceeds to add_physical_form step after adding shades" do
      post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue] }))
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :add_physical_form))
    end

    it "proceeds to contains_special_applicator step after physical form" do
      post(:update, params: params.merge(id: :add_physical_form, component: { physical_form: "loose powder" }))
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :contains_special_applicator))
    end

    it "proceeds to select_special_applicator_type step if the product come in an applicator" do
      post(:update, params: params.merge(id: :contains_special_applicator, component: { contains_special_applicator: "yes" }))
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :select_special_applicator_type))
    end

    it "skips select_special_applicator_type step if the product doesn't come in an applicator" do
      post(:update, params: params.merge(id: :contains_special_applicator, component: { contains_special_applicator: "no" }))
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :contains_cmrs))
    end

    it "proceeds to contains_cmrs step after selecting the special applicator type" do
      post(:update, params: params.merge(id: :select_special_applicator_type, component: { special_applicator: "wipe_sponge_patch_pad" }))
      expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :contains_cmrs))
    end

    it "adds non empty cmrs to the component when add_cmrs" do
      cmr_name = "ABC"
      cmrs_params = params.merge(id: :add_cmrs, component: { cmrs_attributes: { "0": { name: cmr_name }, "1": { name: "" } } })

      post(:update, params: cmrs_params)
      expect(assigns(:component).cmrs.count).to eq(1)
      expect(assigns(:component).cmrs.first.name).to eq(cmr_name)
    end

    context "when selecting a frame formulation" do
      it "saves and redirects to the 'poisonous ingredients' question if you select an answer" do
        post(:update, params: params.merge(id: :select_frame_formulation, component: { frame_formulation: "skin_care_cream_lotion_gel" }))

        expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :contains_poisonous_ingredients))
      end

      it "re-renders the question with an error if you don’t select a formulation" do
        post(:update, params: params.merge(id: :select_frame_formulation, component: { frame_formulation: "" }))

        expect(response.status).to be(200)
        expect(assigns(:component).errors[:frame_formulation]).to include("Frame formulation can not be blank")
      end
    end

    context "when selecting whether the component contains poisonous materials" do
      context "when an answer is provided" do
        let(:answer) { "true" }

        before { post(:update, params: params.merge(id: :contains_poisonous_ingredients, component: { contains_poisonous_ingredients: answer })) }

        it "saves the component record" do
          expect(assigns(:component).contains_poisonous_ingredients).to be(true)
        end

        context "when the answer is true" do
          it "redirects to the upload formulation page" do
            expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :upload_formulation))
          end
        end

        context "when the answer is true" do
          let(:answer) { "false" }

          it "redirects to the select pH range page" do
            expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, notification, component, :select_ph_range))
          end
        end
      end

      context "with no answer provided" do
        before { post(:update, params: params.merge(id: :contains_poisonous_ingredients)) }

        it "re-renders the question with an error" do
          expect(response.status).to be(200)
          expect(assigns(:component).errors[:contains_poisonous_ingredients]).to include("Select whether the product contains any poisonous ingredients")
        end
      end
    end

    context "when notified pre EU-exit" do
      before do
        params.merge!(notification_reference_number: pre_eu_exit_notification.reference_number)
      end

      it "redirects to contains_cmrs if pre-eu-exit" do
        post(:update, params: params.merge(id: :add_physical_form, component: { physical_form: "loose powder" }))
        expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, pre_eu_exit_notification, component, :contains_cmrs))
      end

      it "skips contains poisonous ingredients question and redirects to PH question" do
        post(:update, params: params.merge(id: :select_frame_formulation, component: { frame_formulation: "skin_care_cream_lotion_gel" }))

        expect(response).to redirect_to(responsible_person_notification_component_trigger_question_path(responsible_person, pre_eu_exit_notification, component, :select_ph_range))
      end
    end
  end

private

  def other_responsible_person_params
    other_responsible_person = create(:responsible_person)
    other_notification = create(:notification, components: [create(:component)], responsible_person: other_responsible_person)
    other_component = other_notification.components.first

    {
      responsible_person_id: other_responsible_person.id,
      notification_reference_number: other_notification.reference_number,
      component_id: other_component.id,
    }
  end
end
