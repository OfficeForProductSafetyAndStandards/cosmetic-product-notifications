require "rails_helper"

RSpec.describe "Contact person pages", type: :request do
  let(:responsible_person) { create(:responsible_person, :with_no_contact_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "adding a contact person" do
    context "with all the required details" do
      before do
        stub_notify_mailer
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

      it "sends a welcome email to that contact" do
        expect(NotifyMailer).to have_received(:send_contact_person_verification_email)
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

  describe "viewing the edit form" do
    let(:contact_person) { create(:contact_person, responsible_person: responsible_person) }

    before do
      get "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}/edit"
    end

    it "is successful" do
      expect(response.status).to be 200
    end
  end

  describe "updating the contact person’s details" do
    let(:contact_person) {
      create(:contact_person,
             name: "Alpha Person",
             email_address: "alpha@example.com",
             phone_number: "07711 111111",
             responsible_person: responsible_person)
    }

    context "with all the required fields" do
      before do
        put "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}", params: {
          contact_person: {
            name: "Beta Person",
            email_address: "beta@example.com",
            phone_number: "07722 222222",
          },
        }
      end

      it "redirects to the notifications dashboard" do
        expect(response).to redirect_to("/responsible_persons/#{responsible_person.id}/notifications")
      end

      it "updates the contact person’s details" do
        expect(contact_person.reload).to have_attributes(
          name: "Beta Person",
          email_address: "beta@example.com",
          phone_number: "07722 222222",
        )
      end
    end

    context "with a required field missing" do
      before do
        put "/responsible_persons/#{responsible_person.id}/contact_persons/#{contact_person.id}", params: {
          contact_person: {
            name: "Alpha Person",
            email_address: "alpha@example.com",
            phone_number: "",
          },
        }
      end

      it "renders a page instead of redirecting" do
        expect(response.status).to be 200
      end

      it "displays an error message" do
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
  end
end
