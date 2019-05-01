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

  describe "resend_email" do
    it "creates a new verification key" do
      stub_notify_mailer

      get :resend_email, params: { responsible_person_id: responsible_person.id }

      expect(NotifyMailer).to have_received(:send_responsible_person_verification_email)
    end
  end
end
