require "rails_helper"

RSpec.describe NotifyMailer, type: :mailer do
  let(:responsible_person) { create(:responsible_person) }
  let(:user_name) { "Test User" }
  let(:email_address) { "user@example.com" }

  describe "send_responsible_person_verification_email" do
    it "sends new email verification key to responsible person" do
      mail = NotifyMailer.send_responsible_person_verification_email(responsible_person.id, responsible_person.contact_persons.first.email_address, user_name)
      expect(mail.to).to eq([responsible_person.contact_persons.first.email_address])
      expect(responsible_person.reload.email_verification_keys.size).to eq(1)
    end
  end

  describe "send_responsible_person_invite_email" do
    it "sends invite to join a responsible person to invited user" do
      mail = NotifyMailer.send_responsible_person_invite_email(responsible_person.id, responsible_person.name, email_address, user_name)
      expect(mail.to).to eq([email_address])
      expect(responsible_person.reload.pending_responsible_person_users.size).to eq(1)
    end
  end
end
