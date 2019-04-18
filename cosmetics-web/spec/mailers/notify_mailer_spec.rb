require "rails_helper"

RSpec.describe NotifyMailer, type: :mailer do
  let(:responsible_person) { create(:responsible_person) }
  let(:user_name) { "Test User" }
  let(:email_address) { "user@example.com" }

  describe "send_responsible_person_verification_email" do
    it "sends new email verification key to responsible person" do
      mail = NotifyMailer.send_responsible_person_verification_email(responsible_person.id,
      responsible_person.contact_persons.first.email_address, "contact name", "responsible_person name", user_name)
      expect(mail.to).to eq([responsible_person.contact_persons.first.email_address])
      expect(responsible_person.reload.email_verification_keys.size).to eq(1)
    end
  end
end
