require "rails_helper"

RSpec.describe RemoveExpiredEmailVerificationKeysJob, :type => :job do
  let(:email_verification_key) {create(:email_verification_key)}
  let(:expired_email_verification_key) {create(:expired_email_verification_key)}

  before do
    email_verification_key.save
    expired_email_verification_key.save
  end

  describe "#perform" do
    it "deletes an expired key" do
      RemoveExpiredEmailVerificationKeysJob.perform_now

      expect(EmailVerificationKey.count).to eq(1)
    end
  end
end