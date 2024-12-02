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

    if sanitized_number.start_with?("+")
      phone = Phonelib.parse(sanitized_number)
      return phone.e164 if phone.valid?
    else
      inferred_number = infer_country_code(sanitized_number)
      if inferred_number
        phone = Phonelib.parse(inferred_number)
        return phone.e164 if phone.valid?
      end
    end

    nil
  end

  def self.sanitize_number(number)
    number.strip.gsub(/[^0-9+]/, "").sub(/\A\+{2,}/, "+")
  end

  def self.infer_country_code(number)
    if number.start_with?("00")
      "+#{number[2..]}"
    elsif number.start_with?("0")
      "+44#{number[1..]}"
    end
  end
end
