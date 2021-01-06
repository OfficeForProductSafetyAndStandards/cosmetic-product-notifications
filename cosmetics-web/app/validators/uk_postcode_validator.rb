class UkPostcodeValidator < ActiveModel::EachValidator
  # We start by making sure our postcode isn't surrounded by anything else in our field,
  # so we encase it between a beginning (\A) and an end (\z) of string.
  # Then, we accept one or two letters [a-zA-Z]{1,2}
  # Followed by either one digit and a letter, or between one and two digits: ([0-9]{1,2}|[0-9][a-zA-Z])
  # An optional space \s*
  # Finally, a digit followed by two letters: [0-9][a-zA-Z]{2}
  # Source: https://coderwall.com/p/rnucjg/regexp-how-to-validate-a-uk-postcode
  UK_POSTCODE_REGEX = /\A[a-zA-Z]{1,2}([0-9]{1,2}|[0-9][a-zA-Z])\s*[0-9][a-zA-Z]{2}\z/.freeze
  ERROR_MSG = "Enter a UK postcode".freeze

  def validate_each(record, attribute, value)
    unless UK_POSTCODE_REGEX.match?(value)
      record.errors.add attribute, (options[:message] || ERROR_MSG)
    end
  end
end
