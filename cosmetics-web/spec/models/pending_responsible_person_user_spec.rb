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
      expect(pending_responsible_person.errors[:email_address]).to include("Enter email address")
    end

    it "fails if an invalid email is specified" do
      pending_responsible_person.email_address = "invalid-email"

      expect(pending_responsible_person.save).to be false
      expect(pending_responsible_person.errors[:email_address]).to include("Enter email address in the correct format, like name@example.com")
    end

    it "fails if the email is already a member of team" do
      create(:responsible_person_user,
             user: create(:submit_user, email: pending_responsible_person.email_address),
             responsible_person: pending_responsible_person.responsible_person)

      expect(pending_responsible_person.save).to be false
      expect(pending_responsible_person.errors[:email_address]).to include("This email address already belongs to member of this team")
    end

    it "fails if the email is already used on user for the same team" do
      create(:pending_responsible_person_user,
             email_address: pending_responsible_person.email_address,
             responsible_person: pending_responsible_person.responsible_person)

      expect(pending_responsible_person.save).to be false
      expect(pending_responsible_person.errors[:email_address]).to include("This person has already been invited to this team")
    end

    it "create record if the email is already used on user for a different team" do
      create(:pending_responsible_person_user,
             email_address: pending_responsible_person.email_address)

      expect(pending_responsible_person.save).to be true
      expect(pending_responsible_person.errors).to be_empty
    end

    context "when inviting existing search user (by mistake)" do
      let(:search_user) { create(:search_user) }
      let(:pending_responsible_person) { build(:pending_responsible_person_user, email_address: search_user.email) }

      it "succeeds when all required attributes are specified" do
        expect(pending_responsible_person.save).to be true
      end
    end
  end
end
