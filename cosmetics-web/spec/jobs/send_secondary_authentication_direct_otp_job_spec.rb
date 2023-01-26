require "rails_helper"

RSpec.describe SendSecondaryAuthenticationDirectOtpJob do
  let(:user) { create(:submit_user) }
  let(:code) { 123 }

  it "send the otp code" do
    allow(SendSubmitSms).to receive(:otp_code)

    described_class.perform_now(user, code)

    expect(SendSubmitSms)
      .to have_received(:otp_code)
      .with(mobile_number: user.mobile_number, code:)
  end
end
