require "rails_helper"

RSpec.describe SendSecondaryAuthenticationDirectOtpJob do
  let(:code) { 123 }

  context "when the user is a submit user" do
    let(:user) { create(:submit_user) }

    it "send the otp code" do
      allow(SendSubmitSms).to receive(:otp_code)

      described_class.perform_now(user, code)

      expect(SendSubmitSms)
        .to have_received(:otp_code)
        .with(mobile_number: user.mobile_number, code:)
    end
  end

  context "when the user is a search user" do
    let(:user) { create(:search_user) }

    it "send the otp code" do
      allow(SendSearchSms).to receive(:otp_code)

      described_class.perform_now(user, code)

      expect(SendSearchSms)
        .to have_received(:otp_code)
        .with(mobile_number: user.mobile_number, code:)
    end
  end

  context "when the user is a support user" do
    let(:user) { create(:support_user) }

    it "send the otp code" do
      allow(SendSupportSms).to receive(:otp_code)

      described_class.perform_now(user, code)

      expect(SendSupportSms)
        .to have_received(:otp_code)
        .with(mobile_number: user.mobile_number, code:)
    end
  end
end
