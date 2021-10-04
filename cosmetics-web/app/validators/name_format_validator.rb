class NameFormatValidator < ActiveModel::EachValidator
  BANNED_REGEXP = /:|\/|@|<|>|,|\.|\n|www|http/.freeze
  DEFAULT_MESSAGE = "Enter a valid name".freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    if BANNED_REGEXP.match? value
      record.errors.add(attribute, options[:message] || DEFAULT_MESSAGE)
    end
  end
end
