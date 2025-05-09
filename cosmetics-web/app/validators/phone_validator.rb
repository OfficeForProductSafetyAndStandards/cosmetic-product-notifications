# Validates the phone numbers following the validation rules stablished by
# GOV.UK Notifications API in:
# https://github.com/alphagov/notifications-utils/blob/master/notifications_utils/recipients.py
#
# The reasoning behind aligning the validations against gov uk API is that we want
# to avoid allowing phone numbers that later are rejected by the Gov.uk API when
# attempting to send them a 2FA code.
class PhoneValidator < ActiveModel::EachValidator
  class InvalidPhoneError < StandardError; end

  class PhoneTooShortError < InvalidPhoneError
    def message
      "Not enough digits"
    end
  end

  class PhoneTooLongError < InvalidPhoneError
    def message
      "Too many digits"
    end
  end

  class InvalidCountryError < InvalidPhoneError
    def message
      "Not a valid country prefix"
    end
  end

  class NotUKPhoneError < InvalidPhoneError
    def message
      "Not a valid country prefix"
    end
  end

  class BadFormatError < InvalidPhoneError
    def message
      "Must not contain letters or symbols"
    end
  end

  WHITESPACES = [
    " ",       # Standard whitespace
    "\u180E",  # Mongolian vowel separator
    "\u200B",  # zero width space
    "\u200C",  # zero width non-joiner
    "\u200D",  # zero width joiner
    "\u2060",  # word joiner
    "\u00A0",  # non breaking space
    "\uFEFF",  # zero width non-breaking space
  ].freeze
  DOUBLE_ZERO = "00".freeze
  INTERNATIONAL_MAX_LENGTH = 15
  INTERNATIONAL_MIN_LENGTH = 8
  INTERNATIONAL_CODES_FILE_PATH = "config/constants/international_phone_codes.yml".freeze
  PHONE_NUMBER_SYMBOLS = %w[( ) + -].freeze
  STRINGS_TO_CLEAN = WHITESPACES + PHONE_NUMBER_SYMBOLS
  UK_MOBILE_LENGTH = 10
  UK_MIN_LANDLINE_LENGHT = 7
  UK_MAX_LANDLINE_LENGHT = 10
  UK_MOBILE_PREFIX = "7".freeze
  UK_PREFIX = "44".freeze
  ZERO = "0".freeze

  def validate_each(record, attribute, value)
    validate_phone_number(value, options[:allow_international] || false, options[:allow_landline] || false)
  rescue InvalidPhoneError => e
    record.errors.add(attribute, options[:message] || e.message)
  end

private

  def validate_phone_number(number, allow_international, allow_landline)
    return validate_uk_phone_number(number, allow_landline) if uk_phone_number?(number)
    raise NotUKPhoneError unless allow_international

    normalised_number = normalise_phone_number(number)
    raise PhoneTooShortError if normalised_number.length < INTERNATIONAL_MIN_LENGTH
    raise PhoneTooLongError if normalised_number.length > INTERNATIONAL_MAX_LENGTH
    raise InvalidCountryError if international_prefix(normalised_number).blank?

    number
  end

  def uk_phone_number?(phone_number)
    return true if phone_number.start_with?(ZERO) && !phone_number.start_with?(DOUBLE_ZERO)

    number = normalise_phone_number(phone_number)
    number.start_with?(UK_PREFIX) ||
      (number.start_with?(UK_MOBILE_PREFIX) && number.length < 11)
  end

  def normalise_phone_number(number)
    cleaned_number = remove_allowed_non_digits(number)
    # All characters are digits (and has at least one digit)
    if cleaned_number.match?(/^\d+$/)
      cleaned_number.sub(/^0+/, "") # Remove any leading 0s
    else
      raise BadFormatError
    end
  end

  def remove_allowed_non_digits(number)
    # Using inject to avoid mutating the original 'number'
    STRINGS_TO_CLEAN.inject(number) do |output, to_clean|
      output.gsub(to_clean, "")
    end
  end

  def validate_uk_phone_number(number, allow_landline)
    number = normalise_phone_number(number).delete_prefix(UK_PREFIX).delete_prefix(ZERO)
    raise NotUKPhoneError unless number.start_with?(UK_MOBILE_PREFIX) || allow_landline

    validate_uk_number_length(number, allow_landline)
    UK_PREFIX + number
  end

  def validate_uk_number_length(number, allow_landline)
    if allow_landline
      raise PhoneTooLongError if number.length > UK_MAX_LANDLINE_LENGHT
      raise PhoneTooLongError if number.length < UK_MIN_LANDLINE_LENGHT
    else
      raise PhoneTooLongError if number.length > UK_MOBILE_LENGTH
      raise PhoneTooShortError if number.length < UK_MOBILE_LENGTH
    end
  end

  def international_prefix(number)
    int_codes = YAML.load_file(Rails.root.join(INTERNATIONAL_CODES_FILE_PATH)).keys
    int_codes.find { |code| number.start_with?(code) }
  end
end
