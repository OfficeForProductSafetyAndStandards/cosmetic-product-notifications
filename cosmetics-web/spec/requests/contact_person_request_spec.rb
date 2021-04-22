require "rails_helper"

RSpec.describe "Contact person pages", :with_stubbed_mailer, type: :request do
  let(:responsible_person) { create(:responsible_person) }

  before do
    configure_requests_for_submit_domain
  end

  describe "adding a contact person" do
    before do
      sign_in_as_member_of_responsible_person(responsible_person)
    end

    context "with all the required details" do
      before do
        post "/responsible_persons/#{responsible_person.id}/contact_persons", params: {
          contact_person: {
            name: "Test Person",
            email_address: "test@example.com",
            phone_number: "07712 345678",
          },
        }
      end

      it "redirects to the notifications dashboard" do
        expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications")
      end

      it "saves the contact person’s details" do
        expect(responsible_person.reload.contact_persons.first).to have_attributes(
          name: "Test Person",
          email_address: "test@example.com",
          phone_number: "07712 345678",
        )
      end
    end

    context "with the required details missing" do
      before do
        post "/responsible_persons/#{responsible_person.id}/contact_persons", params: {
          contact_person: {
            name: "",
            email_address: "",
            phone_number: "",
          },
        }
      end

      it "renders a page" do
        expect(response.status).to be 200
      end

      it "displays an error message" do
        expect(response.body).to include("There is a problem")
      end

      it "does not save the contact person" do
        expect(responsible_person.reload.contact_persons.count).to be 0
      end
    end
  end

  describe "viewing the edit pages" do
    let(:contact_person) { create(:contact_person, responsible_person: responsible_person) }

    context "when signed in as a member of the Contact Person Responsible Person" do
      before do
        sign_in_as_member_of_responsible_person(responsible_person)
      end

      it "can access the edit name page" do
        get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=name"
        expect(response.status).to be 200
      end

      it "can access the edit email address page" do
        get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=email_address"
        expect(response.status).to be 200
      end

      it "can access the edit phone number page" do
        get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=phone_number"
        expect(response.status).to be 200
      end

      it "can't access the edit page without a field" do
        get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit"
        expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}")
      end

      it "can't access the edit page for an invalid field" do
        get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=foobar"
        expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}")
      end
    end

    context "when the signed in user is not a member of the Contact Person Responsible Person" do
      let(:user) { create(:submit_user) }

      before do
        sign_in(user)
      end

      it "cannot access edit name page" do
        expect {
          get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=name"
        }.to raise_error(Pundit::NotAuthorizedError)
      end

      it "cannot access edit email address page" do
        expect {
          get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=email_address"
        }.to raise_error(Pundit::NotAuthorizedError)
      end

      it "cannot access edit phone number page" do
        expect {
          get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=phone_number"
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when not signed in" do
      it "cannot access edit name page" do
        get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=name"
        expect(response).to redirect_to("/sign-in")
      end

      it "cannot access edit email address page" do
        get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=email_address"
        expect(response).to redirect_to("/sign-in")
      end

      it "cannot access edit phone number page" do
        get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit?field=phone_number"
        expect(response).to redirect_to("/sign-in")
      end
    end
  end

  describe "updating the contact person’s details" do
    RSpec.shared_examples "validation error" do
      it "renders a page instead of redirecting" do
        expect(response.status).to be 200
      end

      it "includes a validation error message in the response" do
        expect(response.body).to include("There is a problem")
      end

      it "does not update the contact person’s details" do
        expect(contact_person.reload).to have_attributes(
          name: "Alpha Person",
          email_address: "alpha@example.com",
          phone_number: "07711 111111",
        )
      end
    end

    RSpec.shared_examples "not changed" do
      it "redirects to the responsible person page" do
        expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}")
      end

      it "does not update contact person details" do
        expect(contact_person.reload).to have_attributes(
          name: "Alpha Person",
          email_address: "alpha@example.com",
          phone_number: "07711 111111",
        )
      end

      it "does not include a confirmation message in the response" do
        expect(response.body).not_to include("changed successfully")
      end
    end

    let(:contact_person) do
      create(:contact_person,
             name: "Alpha Person",
             email_address: "alpha@example.com",
             phone_number: "07711 111111",
             responsible_person: responsible_person)
    end
    let(:contact_person_params) { {} }

    before do
      sign_in_as_member_of_responsible_person(responsible_person)
      put "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}",
          params: { contact_person: contact_person_params }
    end

    describe "updating name" do
      context "when providing a name" do
        let(:contact_person_params) { { name: "Beta Person" } }

        it "redirects to the responsible person page" do
          expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}")
        end

        it "updates the contact person’s name" do
          expect(contact_person.reload).to have_attributes(
            name: "Beta Person",
            email_address: "alpha@example.com",
            phone_number: "07711 111111",
          )
        end

        it "response includes a confirmation message" do
          follow_redirect!
          expect(response.body).to include("Contact person name changed successfully")
        end
      end

      context "when name is missing" do
        let(:contact_person_params) { { name: "" } }

        include_examples "validation error"
      end

      context "when the given name is the same as the current one" do
        let(:contact_person_params) { { name: "Alpha Person" } }

        include_examples "not changed"
      end
    end

    describe "updating email address" do
      context "when providing an email" do
        let(:contact_person_params) { { email_address: "beta@example.com" } }

        it "redirects to the responsible person page" do
          expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}")
        end

        it "updates the contact person’s email address" do
          expect(contact_person.reload).to have_attributes(
            name: "Alpha Person",
            email_address: "beta@example.com",
            phone_number: "07711 111111",
          )
        end

        it "response includes a confirmation message" do
          follow_redirect!
          expect(response.body).to include("Contact person email address changed successfully")
        end
      end

      context "when email address format is wrong" do
        let(:contact_person_params) { { email_address: "wrongFormat" } }

        include_examples "validation error"
      end

      context "when the given email address is the same as the current one" do
        let(:contact_person_params) { { email_address: "alpha@example.com" } }

        include_examples "not changed"
      end
    end

    describe "updating phone number" do
      context "when providing a phone number" do
        let(:contact_person_params) { { phone_number: "07722 222222" } }

        it "redirects to the responsible person page" do
          expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}")
        end

        it "updates the contact person’s phone number" do
          expect(contact_person.reload).to have_attributes(
            name: "Alpha Person",
            email_address: "alpha@example.com",
            phone_number: "07722 222222",
          )
        end

        it "response includes a confirmation message" do
          follow_redirect!
          expect(response.body).to include("Contact person phone number changed successfully")
        end
      end

      context "when phone number format is wrong" do
        let(:contact_person_params) { { phone_number: "000" } }

        include_examples "validation error"
      end

      context "when the given phone number is the same as the current one" do
        let(:contact_person_params) { { phone_number: "07711 111111" } }

        include_examples "not changed"
      end
    end
  end
end
