class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    mail = Mail::Address.new(value)

    unless email_accepted?(mail, value)
      record.errors.add(attribute, options[:message])
    end
  rescue Mail::Field::ParseError
    record.errors.add(attribute, options[:message])
  end

private

  def email_accepted?(parsed_email, value)
    parsed_email.address == value && # Parsed address corresponds to introduced value
      parsed_email.address =~ URI::MailTo::EMAIL_REGEXP && # Valid email format
      parsed_email.domain.split(".").length > 1 # Exclude local domains (eg: user@example)
  end
end
