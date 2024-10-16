class SendSupportSms
  TEMPLATES = {
    otp_code: "08956201-a0a5-498d-bdd7-857af6d2a858",
  }.freeze

  attr_reader :client

  def initialize
    @client = Notifications::Client.new(Rails.configuration.support_notify_api_key)
  end

  def self.otp_code(mobile_number:, code:)
    new.client.send_sms(
      phone_number: mobile_number,
      template_id: TEMPLATES[:otp_code],
      personalisation: { code: },
    )
  end
end
