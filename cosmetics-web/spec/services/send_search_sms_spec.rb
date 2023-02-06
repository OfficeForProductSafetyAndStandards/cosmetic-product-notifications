require "rails_helper"

RSpec.describe SendSearchSms, :with_stubbed_notify do
  describe ".otp_code" do
    let(:phone_number) { "123234234" }
    let(:code) { 123 }
    let(:expected_payload) do
      { phone_number:, template_id: described_class::TEMPLATES[:otp_code], personalisation: { code: } }
    end

    it "sends the otp code" do
      described_class.otp_code(mobile_number: phone_number, code:)

      expect(notify_stub).to have_received(:send_sms).with(expected_payload)
    end
  end
end
