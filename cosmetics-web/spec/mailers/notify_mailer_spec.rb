require "rails_helper"

RSpec.describe NotifyMailer, type: :mailer do
  let(:responsible_person) { create(:responsible_person) }
  let(:contact_person) { responsible_person.contact_persons.first }

  let(:user_name) { "Test User" }
  let(:email_address) { "user@example.com" }

  describe "send_contact_person_verification_email" do
    it "sends new email verification key to contact person" do
      mail = NotifyMailer.send_contact_person_verification_email(contact_person, responsible_person.name, user_name)
      expect(mail.to).to eq([responsible_person.contact_persons.first.email_address])
      expect(contact_person.reload.email_verification_key).not_to be_nil
    end
  end

  describe "send_responsible_person_invite_email" do
    it "sends invite to join a responsible person to invited user" do
      mail = NotifyMailer.send_responsible_person_invite_email(responsible_person.id, responsible_person.name, email_address, user_name)
      expect(mail.to).to eq([email_address])
    end
  end
end
