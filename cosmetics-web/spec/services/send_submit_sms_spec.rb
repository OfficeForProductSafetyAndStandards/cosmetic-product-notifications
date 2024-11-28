require "rails_helper"

RSpec.describe SendSubmitSms, :with_stubbed_notify do
  describe ".otp_code" do
    let(:phone_number) { "+447500000000" }
    let(:code) { 123 }
    let(:expected_payload) do
      { phone_number:, template_id: described_class::TEMPLATES[:otp_code], personalisation: { code: } }
    end

    it "sends the otp code with a valid phone number" do
      described_class.otp_code(mobile_number: phone_number, code:)

      expect(notify_stub).to have_received(:send_sms).with(expected_payload)
    end

    it "raises an error with an invalid phone number" do
      invalid_phone_number = "1234"

      expect {
        described_class.otp_code(mobile_number: invalid_phone_number, code:)
      }.to raise_error(ArgumentError, "Invalid mobile number provided: #{invalid_phone_number}")
    end
  end
end
