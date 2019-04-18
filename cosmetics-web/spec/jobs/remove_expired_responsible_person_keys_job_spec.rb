require "rails_helper"

RSpec.describe RemoveExpiredResponsiblePersonKeysJob, type: :job do
  let(:responsible_person) { create(:responsible_person) }
  let(:email_verification_key) { create(:email_verification_key) }
  let(:expired_email_verification_key) { create(:expired_email_verification_key) }
  let(:pending_responsible_person_user) { create(:pending_responsible_person_user, responsible_person: responsible_person, email_address: "pending1@example.com") }
  let(:expired_pending_responsible_person_user) { create(:expired_pending_responsible_person_user, responsible_person: responsible_person, email_address: "pending2@example.com") }

  before do
    email_verification_key.save
    expired_email_verification_key.save
    pending_responsible_person_user.save
    expired_pending_responsible_person_user.save
  end

  describe "#perform" do
    it "deletes an expired email verification key" do
      RemoveExpiredResponsiblePersonKeysJob.perform_now

      expect(EmailVerificationKey.count).to eq(1)
    end

    it "deletes an expired pending responsible person user" do
      RemoveExpiredResponsiblePersonKeysJob.perform_now

      expect(PendingResponsiblePersonUser.count).to eq(1)
    end
  end
end
