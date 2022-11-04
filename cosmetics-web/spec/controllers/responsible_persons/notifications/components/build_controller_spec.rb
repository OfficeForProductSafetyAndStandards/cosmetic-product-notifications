require "rails_helper"

RSpec.describe ResponsiblePersons::Notifications::Components::BuildController, type: :controller do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }
  let(:component) { create(:component, notification:, notification_type: component_type) }
  let(:notification) do
    create(:notification,
           responsible_person:,
           state: NotificationStateConcern::READY_FOR_COMPONENTS)
  end
  let(:component_type) { nil }

  let(:params) do
    {
      responsible_person_id: responsible_person.id,
      notification_reference_number: notification.reference_number,
      component_id: component.id,
    }
  end

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  describe "GET #new" do
    it "redirects to the first step of the wizard" do
      get(:new, params:)
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

    it "initialises shades array with two empty strings in add_shades step" do
      get(:show, params: params.merge(id: :add_shades))
      expect(assigns(:component).shades).to eq(["", ""])
    end

    it "does not allow the user to view a notification component for a Responsible Person they not belong to" do
      expect {
        get(:show, params: other_responsible_person_params.merge(id: :number_of_shades))
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    context "when the notification is already submitted" do
      subject(:request) { get(:show, params: params.merge(id: :number_of_shades)) }

      let(:notification) { create(:registered_notification, responsible_person:) }

      it "redirects to the notifications page" do
        expect(request).to redirect_to(responsible_person_notification_path(responsible_person, notification))
      end
    end

    it "initialises 5 empty cmrs in add_cmrs step" do
      get(:show, params: params.merge(id: :add_cmrs))
      expect(assigns(:component).cmrs).to have(5).items
      expect(assigns(:component).cmrs).to all(have_attributes(name: be_nil))
    end

    describe "add component predefined frame formulation poisonous ingredient" do
      let(:component_type) { "predefined" }

      before { get(:show, params: params.merge(id: :add_poisonous_ingredient)) }

      render_views

      # rubocop:disable RSpec/MultipleExpectations
      it "shows the page for adding poisonous ingredients to a predefined formulation component" do
        expect(response.body).to match(/<title>Add the poisonous ingredients .+<\/title>/)
        expect(response.body).to include("What is the exact concentration?")
        expect(response.body).not_to include("What is the concentration range?")
      end
      # rubocop:enable RSpec/MultipleExpectations

      it " contains a back link to the 'ingredients the NPIS needs to know about' page" do
        expect(response.body).to have_back_link_to(
          responsible_person_notification_component_build_path(
            responsible_person, notification, component, :contains_ingredients_npis_needs_to_know
          ),
        )
      end
    end

    describe "add component ingredient exact concentration page" do
      let(:component_type) { "exact" }

      before { get(:show, params: params.merge(id: :add_ingredient_exact_concentration)) }

      render_views

      # rubocop:disable RSpec/MultipleExpectations
      it "shows the page for adding ingredients with exact concentration" do
        expect(response.body).to match(/<title>Add the ingredients .+<\/title>/)
        expect(response.body).to include("What is the exact concentration?")
        expect(response.body).not_to include("What is the concentration range?")
      end
      # rubocop:enable RSpec/MultipleExpectations

      it "links to the select formulation type page" do
        expect(response.body).to have_back_link_to(
          responsible_person_notification_component_build_path(responsible_person, notification, component, :select_formulation_type),
        )
      end
    end

    describe "add component ingredient range concentration page" do
      let(:component_type) { "range" }

      before { get(:show, params: params.merge(id: :add_ingredient_range_concentration)) }

      render_views

      it "shows the page for adding ingredients with exact concentration" do
        expect(response.body).to match(/<title>Add the ingredients .+<\/title>/)
        expect(response.body).to include("What is the concentration range?")
      end

      it "links to the select formulation type page" do
        expect(response.body).to have_back_link_to(
          responsible_person_notification_component_build_path(responsible_person, notification, component, :select_formulation_type),
        )
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
      expect(assigns(:component).errors[:number_of_shades]).to eql(["Select yes if the product is available in shades"])
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

    context "when the notification is already submitted" do
      subject(:request) { post(:update, params: params.merge(id: :add_shades, component: { shades: %w[red blue] })) }

      let(:notification) { create(:registered_notification, responsible_person:) }

      it "redirects to the notifications page" do
        expect(request).to redirect_to(responsible_person_notification_path(responsible_person, notification))
      end
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
      it "saves and redirects to the 'ingredients the NPIS needs to know about' question if you select an answer" do
        post(:update, params: params.merge(id: :select_frame_formulation, component: { frame_formulation: "skin_care_cream_lotion_gel" }))

        expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :contains_ingredients_npis_needs_to_know))
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

        before do
          post(:update, params: params.merge(id: :contains_ingredients_npis_needs_to_know,
                                             component: { contains_ingredients_npis_needs_to_know: answer }))
        end

        it "saves the component record" do
          expect(assigns(:component).contains_poisonous_ingredients).to be(true)
        end

        context "when the answer is true" do
          it "redirects to the add poisonous ingredient" do
            expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :add_poisonous_ingredient))
          end
        end

        context "when the answer is false" do
          let(:answer) { "false" }

          it "redirects to the select pH range page" do
            expect(response).to redirect_to(responsible_person_notification_component_build_path(responsible_person, notification, component, :select_ph_option))
          end
        end
      end

      context "with no answer provided" do
        before { post(:update, params: params.merge(id: :contains_ingredients_npis_needs_to_know)) }

        it "re-renders the question with an error" do
          expect(response.status).to be(200)
          expect(assigns(:component).errors[:contains_ingredients_npis_needs_to_know])
            .to include("Select yes if the product contains ingredients the NPIS needs to know about")
        end
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
