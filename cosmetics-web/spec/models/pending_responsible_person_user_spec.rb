require "rails_helper"

RSpec.describe PendingResponsiblePersonUser, type: :model do
  let(:pending_responsible_person) { build(:pending_responsible_person_user) }

  describe "create record" do
    it "succeeds when all required attributes are specified" do
      expect(pending_responsible_person.save).to be true
    end

    it "fails if an email is not specified" do
      pending_responsible_person.email_address = nil

      expect(pending_responsible_person.save).to be false
      expect(pending_responsible_person.errors[:email_address]).to include("Email address can not be blank")
    end

    it "fails if an invalid email is specified" do
      pending_responsible_person.email_address = "invalid-email"

      expect(pending_responsible_person.save).to be false
      expect(pending_responsible_person.errors[:email_address]).to include("Email address is invalid")
    end

    it "fails if the email is already a member of team" do
      create(:responsible_person_user,
             user: create(:submit_user, email: pending_responsible_person.email_address),
             responsible_person: pending_responsible_person.responsible_person)

      expect(pending_responsible_person.save).to be false
      expect(pending_responsible_person.errors[:email_address]).to include("The email address is already a member of this team")
    end

    it "succeeds when the email is already in pending request but does not add a new instance" do
      pending_responsible_person.save
      pending_responsible_person_same_email = build(:pending_responsible_person_user, email_address: pending_responsible_person.email_address,
                                                    responsible_person: pending_responsible_person.responsible_person)

      expect { pending_responsible_person_same_email.save }.not_to change(described_class, :count)
      expect(pending_responsible_person_same_email.save).to be true
    end
  end
end
