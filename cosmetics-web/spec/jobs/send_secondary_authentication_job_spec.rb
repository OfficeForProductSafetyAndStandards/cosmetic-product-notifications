require "rails_helper"

RSpec.describe SendSecondaryAuthenticationJob do
  let(:user) { create(:user) }
  let(:code) { 123 }

  it "send the otp code" do
    allow(SendSMS).to receive(:otp_code)

    described_class.perform_now(user, code)

    expect(SendSMS)
      .to have_received(:otp_code)
      .with(mobile_number: user.mobile_number, code: code)
  end
end
