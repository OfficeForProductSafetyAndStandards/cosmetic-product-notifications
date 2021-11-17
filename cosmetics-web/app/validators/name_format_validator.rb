# Abstract Name Validation class.
# Subclasses must define BANNED_REGEXP with a regular expression containing
# invalid name characters/strings.
class NameFormatValidator < ActiveModel::EachValidator
  DEFAULT_MESSAGE = "Enter a valid name".freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    if self.class::BANNED_REGEXP.match? value # BANNED_REGEXP must be defined in subclass
      record.errors.add(attribute, options[:message] || DEFAULT_MESSAGE)
    end
  end
end
