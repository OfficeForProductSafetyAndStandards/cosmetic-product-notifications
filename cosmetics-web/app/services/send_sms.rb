class SendSMS
  TEMPLATES = {
    otp_code: "091c8861-8532-4907-abc0-f89632c34f09",
  }.freeze

  attr_reader :client

  def initialize
    @client = Notifications::Client.new(Rails.configuration.notify_api_key)
  end

  def self.otp_code(mobile_number:, code:)
    new.client.send_sms(
      phone_number: mobile_number,
      template_id: TEMPLATES[:otp_code],
      personalisation: { code: code },
    )
  end
end
