class SendSubmitSMS
  TEMPLATES = {
    otp_code: "9eaabc3a-9eb5-453f-bbbf-624e0cb544f5",
  }.freeze

  attr_reader :client

  def initialize
    @client = Notifications::Client.new(Rails.configuration.submit_notify_api_key)
  end

  def self.otp_code(mobile_number:, code:)
    new.client.send_sms(
      phone_number: mobile_number,
      template_id: TEMPLATES[:otp_code],
      personalisation: { code: code },
    )
  end
end
