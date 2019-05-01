require 'rails_helper'

RSpec.describe ConfirmationController, type: :controller do
  let(:email_verification_key) { create(:email_verification_key) }
  let(:expired_email_verification_key) { create(:expired_email_verification_key) }
  let(:responsible_person) { create(:responsible_person) }

  describe "contact_person" do
    it "redirects to confirmation page if email key has not expired" do
      email_verification_key.update responsible_person: responsible_person
      get :show, params: { key: email_verification_key.key }
      expect(response).to render_template(:show)
    end

    it "redirects to link expired page if key has expired" do
      expired_email_verification_key.update responsible_person: responsible_person
      get :show, params: { key: expired_email_verification_key.key }
      expect(response).to redirect_to link_expired_confirmation_index_path
    end
  end
end
