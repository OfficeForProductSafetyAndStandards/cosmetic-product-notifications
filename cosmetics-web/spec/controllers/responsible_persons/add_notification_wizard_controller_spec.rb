require "rails_helper"

RSpec.describe ResponsiblePersons::Wizard::AddNotificationWizardController, type: :controller do
  let(:responsible_person) { create(:responsible_person, :with_a_contact_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out(:submit_user)
  end

  describe "as a signed in member of the responsible person" do
    describe "GET #show" do
      it "sets the responsible person from the path parameters" do
        get(:show, params: { responsible_person_id: responsible_person.id, id: "have_products_been_notified_in_eu" })
        expect(assigns(:responsible_person)).to eq(responsible_person)
      end
    end

    describe "PUT #update" do
      it "redirects to the correct step for the given answer" do
        put(:update, params: { responsible_person_id: responsible_person.id,
                               id: "have_products_been_notified_in_eu",
                               answer: "yes" })
        expect(response).to redirect_to(responsible_person_add_notification_path(responsible_person, "do_you_have_files_from_eu_notification"))
      end

      it "sets the responsible person from the path parameters" do
        put(:update, params: { responsible_person_id: responsible_person.id, id: "have_products_been_notified_in_eu", answer: "yes" })
        expect(assigns(:responsible_person)).to eq(responsible_person)
      end

      it "renders the current page if no option selected" do
        put(:update, params: { responsible_person_id: responsible_person.id, id: "have_products_been_notified_in_eu" })
        expect(response).to render_template("have_products_been_notified_in_eu")
      end

      it "adds error message if no option selected" do
        put(:update, params: { responsible_person_id: responsible_person.id, id: "have_products_been_notified_in_eu" })
        expect(assigns(:error_text)).to eq("Select yes if the EU has been notified about these products using CPNP")
      end
    end

    describe "GET #new" do
      it "redirects users to the correct first step" do
        get(:new, params: { responsible_person_id: responsible_person.id })
        expect(response).to redirect_to(responsible_person_add_notification_path(responsible_person, "have_products_been_notified_in_eu"))
      end
    end
  end

  describe "as a signed in user who isn't a member of the responsible person" do
    describe "GET #show" do
      it "returns a unauthorised error" do
        other_responsible_person = create(:responsible_person)
        expect { get :show, params: { responsible_person_id: other_responsible_person.id, id: "have_products_been_notified_in_eu" } }
          .to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
