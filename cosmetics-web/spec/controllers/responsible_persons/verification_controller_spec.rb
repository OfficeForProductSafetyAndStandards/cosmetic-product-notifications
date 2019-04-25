require 'rails_helper'

RSpec.describe ResponsiblePersons::VerificationController, type: :controller do
  let(:email_verification_key) { create(:email_verification_key) }
  let(:expired_email_verification_key) { create(:expired_email_verification_key) }
  let(:responsible_person) { create(:responsible_person) }

  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "show" do
    it "verifies ResponsiblePerson if email key exists" do
      email_verification_key.update responsible_person: responsible_person

      get :show, params: { responsible_person_id: responsible_person.id, key: email_verification_key.key }

      expect(responsible_person.contact_persons.first.reload.email_verified).to be true
    end

    it "Redirect to responsible person page if email key exists" do
      email_verification_key.update responsible_person: responsible_person

      get :show, params: { responsible_person_id: responsible_person.id, key: email_verification_key.key }

      expect(response).to redirect_to(responsible_person_path(responsible_person))
    end

    it "redirects to 404 if key does not exist" do
      expect {
        get :show, params: { responsible_person_id: responsible_person.id, key: "fakekey" }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "displays error message 404 if key has expired" do
      expired_email_verification_key.update responsible_person: responsible_person


      get :show, params: { responsible_person_id: responsible_person.id, key: expired_email_verification_key.key }

      expect(response).to render_template(:show)
    end
  end

  describe "resend_email" do
    it "creates a new verification key" do
      stub_notify_mailer

      get :resend_email, params: { responsible_person_id: responsible_person.id }

      expect(NotifyMailer).to have_received(:send_responsible_person_verification_email)
    end
  end
end
