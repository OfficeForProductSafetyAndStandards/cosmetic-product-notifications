class SendSearchSMS
  TEMPLATES = {
    otp_code: "5b58f6e0-5df1-4fc4-aa9e-e008c86fcf90",
  }.freeze

  attr_reader :client

  def initialize
    @client = Notifications::Client.new(Rails.configuration.search_notify_api_key)
  end

  def self.otp_code(mobile_number:, code:)
    new.client.send_sms(
      phone_number: mobile_number,
      template_id: TEMPLATES[:otp_code],
      personalisation: { code: code },
    )
  end
end
