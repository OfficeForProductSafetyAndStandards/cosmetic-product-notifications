require "rails_helper"

RSpec.describe SecondaryAuthentication::DirectOtp do
  let(:attempts) { 0 }
  let(:direct_otp) { "11111" }
  let(:direct_otp_sent_at) { Time.zone.now }
  let(:second_factor_attempts_locked_at) { nil }
  let(:user) { create(:submit_user, second_factor_attempts_count: attempts, direct_otp_sent_at:, second_factor_attempts_locked_at:, direct_otp:) }
  let(:secondary_authentication) { described_class.new(user) }

  describe "#valid_otp?" do
    include_examples "whitelisted OTP tests" do
      let(:whitelisted_otp) { "12345" }
    end

    it "increase attempts when checking code" do
      expect {
        secondary_authentication.valid_otp? "123"
      }.to change { user.reload.second_factor_attempts_count }.from(0).to(1)
    end

    it "returns true" do
      expect(secondary_authentication).to be_valid_otp(user.reload.direct_otp)
    end

    context "when maximum attempts exceeded" do
      let(:attempts) { 11 }

      before do
        secondary_authentication.valid_otp? "123"
      end

      it "sets second_factor_attempts_locked_at" do
        expect(user.reload.second_factor_attempts_locked_at).to be_within(1.second).of(Time.zone.now)
      end

      it "resets attempts count" do
        expect(user.reload.second_factor_attempts_count).to eq(0)
      end

      it "does not increase attempts when checking code" do
        expect {
          secondary_authentication.valid_otp? "123"
        }.not_to(change { user.reload.second_factor_attempts_count })
      end

      it "returns false" do
        expect(secondary_authentication).not_to be_valid_otp(user.reload.direct_otp)
      end

      it "sets second_factor_attempts_count after lock cooldown" do
        travel_to(Time.zone.now + (SecondaryAuthentication::DirectOtp::MAX_ATTEMPTS_COOLDOWN + 1).seconds) do
          expect {
            secondary_authentication.valid_otp? "123"
          }.to change { user.reload.second_factor_attempts_count }.from(0).to(1)
        end
      end

      it "clears second_factor_attempts_locked_at after lock cooldown" do
        travel_to(Time.zone.now + (SecondaryAuthentication::DirectOtp::MAX_ATTEMPTS_COOLDOWN + 1).seconds) do
          secondary_authentication.valid_otp? "123"

          expect(user.reload.second_factor_attempts_locked_at).to eq(nil)
        end
      end
    end
  end

  describe "#otp_locked?" do
    it "returns false when second_factor_attempts_locked_at is empty" do
      expect(secondary_authentication.otp_locked?).to eq(false)
    end

    context "when second_factor_attempts_locked_at is not empty" do
      let(:second_factor_attempts_locked_at) { Time.zone.now }

      it "returns true" do
        expect(secondary_authentication.otp_locked?).to eq(true)
      end

      it "returns false when cooldown passed" do
        travel_to(second_factor_attempts_locked_at + (SecondaryAuthentication::DirectOtp::MAX_ATTEMPTS_COOLDOWN + 1).seconds) do
          expect(secondary_authentication.otp_locked?).to eq(false)
        end
      end
    end
  end
end
