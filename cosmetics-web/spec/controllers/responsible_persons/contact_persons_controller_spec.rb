require 'rails_helper'

RSpec.describe ResponsiblePersons::ContactPersonsController, type: :controller do
  let(:email_verification_key) { create(:email_verification_key) }
  let(:responsible_person) { create(:responsible_person) }
  let(:contact_person) { responsible_person.contact_persons.first }
  let(:params) do
    { responsible_person_id: responsible_person.id,
                     contact_person: { name: contact_person.name, email_address: contact_person.email_address, phone_number: contact_person.phone_number } }
  end

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "create" do
    context "with valid params" do
      it "a new contact person is created" do
        expect {
          post :create, params: params
        }.to change(ContactPerson, :count).by(1)
      end

      it "redirects to show page of a contact person" do
        post :create, params: params

        expect(response).to redirect_to(responsible_person_contact_person_path(responsible_person, contact_person.id + 1))
      end

      it "sends an email to the contact person" do
        stub_notify_mailer

        post :create, params: params

        expect(NotifyMailer).to have_received(:send_contact_person_verification_email)
      end
    end

    context "with invalid params" do
      it "renders back to new contact person form if email address is invalid" do
        post :create, params: params.merge(contact_person: { email_address: "" })
        expect(response).to render_template(:new)
      end
    end
  end

  describe "update" do
    before do
      params.merge! id: contact_person.id
    end

    context "with valid params" do
      it "no new contact person is added" do
        expect {
          put :update, params: params
        }.to change(ContactPerson, :count).by(0)
      end

      it "redirects to show page of a contact person" do
        put :update, params: params

        expect(response).to redirect_to(responsible_person_contact_person_path(responsible_person, contact_person.id))
      end

      it "sends an email to the contact person" do
        stub_notify_mailer

        put :update, params: params

        expect(NotifyMailer).to have_received(:send_contact_person_verification_email)
      end
    end

    context "with invalid params" do
      it "renders back to new contact person form if email address is invalid" do
        put :update, params: params.merge(contact_person: { email_address: "" })
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "resend_email" do
    it "creates a new verification key" do
      stub_notify_mailer

      get :resend_email, params: { responsible_person_id: responsible_person.id, id: contact_person.id }

      expect(NotifyMailer).to have_received(:send_contact_person_verification_email)
    end
  end
end
