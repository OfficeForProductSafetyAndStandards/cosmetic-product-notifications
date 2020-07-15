class PhoneValidator < ActiveModel::EachValidator
  ACCEPTED_PREFIXES = %w[7 07 447 4407 00447].freeze
  DEFAULT_ERROR = "is not a valid phone number".freeze
  ACCEPTED_LENGTH = 10

  def validate_each(record, attribute, value)
    digits = value.delete("^0-9")

    if !digits.start_with?(*ACCEPTED_PREFIXES) || normalised_number(digits).length != ACCEPTED_LENGTH
      record.errors[attribute] << (options[:message] || DEFAULT_ERROR)
    end
  end

private

  def normalised_number(phone_number)
    _prefix, match, after = phone_number.partition("7")
    match + after
  end
end
