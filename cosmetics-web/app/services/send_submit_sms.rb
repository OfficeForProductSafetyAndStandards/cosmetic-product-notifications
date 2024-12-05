require "phonelib"

class SendSubmitSms
  TEMPLATES = {
    otp_code: "9eaabc3a-9eb5-453f-bbbf-624e0cb544f5",
  }.freeze

  attr_reader :client

  def initialize
    @client = Notifications::Client.new(Rails.configuration.submit_notify_api_key)
  end

  def self.otp_code(mobile_number:, code:)
    valid_number = validate_and_format_number(mobile_number)
    if valid_number
      new.client.send_sms(
        phone_number: valid_number,
        template_id: TEMPLATES[:otp_code],
        personalisation: { code: },
      )
    else
      raise ArgumentError, "Invalid mobile number provided: #{mobile_number}"
    end
  end

  def self.validate_and_format_number(number)
    sanitized_number = sanitize_number(number)
    return nil unless sanitized_number

    phone = Phonelib.parse(sanitized_number)
    return phone.e164 if phone.valid?

    inferred_number = infer_country_code(sanitized_number)
    if inferred_number
      phone = Phonelib.parse(inferred_number)
      return phone.e164 if phone.valid?
    end

    nil
  end

  def self.sanitize_number(number)
    sanitized_number = number.strip

    # Remove spaces, hyphens, parentheses, and all '+' signs
    sanitized_number = sanitized_number.gsub(/[\s\-()+]/, "")

    # Replace leading '00' with '+'
    sanitized_number = sanitized_number.sub(/\A00/, "+")

    # Add '+' if the number starts with '44' and doesn't start with '+'
    sanitized_number = "+#{sanitized_number}" if sanitized_number.start_with?("44") && !sanitized_number.start_with?("+")

    # Remove the optional '0' after the UK country code '+44'
    sanitized_number = sanitized_number.sub(/\A(\+44)0/, '\1')

    # Ensure the sanitized number contains only digits and an optional leading '+'
    return nil unless sanitized_number.match?(/\A\+?\d+\z/)

    sanitized_number
  end

  def self.infer_country_code(number)
    if number.start_with?("00")
      "+#{number[2..]}"
    elsif number.start_with?("0")
      "+44#{number[1..]}"
    end
  end
end
