require 'rails_helper'

RSpec.describe ResponsiblePersons::VerificationController, type: :controller do
  before do
    sign_in_as_member_of_responsible_person(responsible_person)
  end

  after do
    sign_out
  end

  describe "show" do
    let(:email_verification_key) { create(:email_verification_key) }
    let(:expired_email_verification_key) { create(:expired_email_verification_key) }
    let(:responsible_person) { create(:responsible_person) }

    it "verifies ResponsiblePerson if email key exists" do
      email_verification_key.responsible_person = responsible_person
      email_verification_key.save

      get :show, params: { responsible_person_id: responsible_person.id, key: email_verification_key.key }

      expect(responsible_person.reload.is_email_verified).to be true
    end

    it "Redirect to responsible person page if email key exists" do
      email_verification_key.responsible_person = responsible_person
      email_verification_key.save

      get :show, params: { responsible_person_id: responsible_person.id, key: email_verification_key.key }

      expect(response).to redirect_to(responsible_person_path(responsible_person))
    end

    it "redirects to 404 if key does not exist" do
      expect {
        get :show, params: { responsible_person_id: responsible_person.id, key: "fakekey" }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "redirects to 404 if key has expired" do
      expired_email_verification_key.responsible_person = responsible_person
      expired_email_verification_key.save

      expect {
        get :show, params: { responsible_person_id: responsible_person.id, key: expired_email_verification_key.key }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
