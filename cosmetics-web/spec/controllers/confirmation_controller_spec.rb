require 'rails_helper'

RSpec.describe ConfirmationController, type: :controller do
  let(:email_verification_key) { create(:email_verification_key) }
  let(:expired_email_verification_key) { create(:expired_email_verification_key) }
  let(:responsible_person) { create(:responsible_person) }

  describe "contact_person" do
    it "redirects to confirmation page if email key exists" do
      email_verification_key.update responsible_person: responsible_person
      get :contact_person, params: { key: email_verification_key.key }
      expect(response).to be_successful
    end

    it "redirects to 404 if key does not exist" do
      get :contact_person, params: { key: email_verification_key.key }
      expect(response).to redirect_to "/404"
    end

    it "redirects to link expired page if key has expired" do
      expired_email_verification_key.update responsible_person: responsible_person
      get :contact_person, params: { key: expired_email_verification_key.key }
      expect(response).to redirect_to link_expired_confirmation_path
    end
  end
end
