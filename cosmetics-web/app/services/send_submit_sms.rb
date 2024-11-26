class SendSubmitSms
  TEMPLATES = {
    otp_code: "9eaabc3a-9eb5-453f-bbbf-624e0cb544f5",
  }.freeze

  attr_reader :client

  def initialize
    @client = Notifications::Client.new(Rails.configuration.submit_notify_api_key)
  end

  def self.otp_code(mobile_number:, code:)
    # Parse the phone number with the default country
    parsed_number = Phonelib.parse(mobile_number, Phonelib.default_country)

    # Validate the phone number
    unless parsed_number.valid?
      raise ArgumentError, "Invalid phone number: #{mobile_number}"
    end

    formatted_number = parsed_number.e164
    Rails.logger.debug("Formatted phone number: #{formatted_number}")

    # Send the SMS
    new.client.send_sms(
      phone_number: formatted_number,
      template_id: TEMPLATES[:otp_code],
      personalisation: { code: },
    )
  rescue Notifications::Client::BadRequestError => e
    Rails.logger.error("Failed to send SMS: #{e.message}")
    raise
  end
end
