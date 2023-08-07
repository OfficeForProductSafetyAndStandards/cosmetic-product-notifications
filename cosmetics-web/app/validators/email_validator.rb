class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    mail = Mail::Address.new(value)

    unless email_accepted?(mail, record, value)
      record.errors.add(attribute, options[:message])
    end
  rescue Mail::Field::ParseError
    record.errors.add(attribute, options[:message])
  end

private

  def email_accepted?(parsed_email, record, value)
    parsed_email.address == value && # Parsed address corresponds to introduced value
      URI::MailTo::EMAIL_REGEXP.match?(value) && # Valid email format
      parsed_email.domain.split(".").length > 1 && # Exclude local domains (eg: user@example)
      /[a-zA-Z]/.match?(value[-1]) && # Last character of the Top Level Domain is a letter
      gov_uk_email_required?(record, value) # Only accept gov.uk email addresses for SupportUser
  end

  def gov_uk_email_required?(record, value)
    (for_support_user?(record) && value.match?(/[\W\w]*gov.uk$/)) || !for_support_user?(record)
  end

  def for_support_user?(record)
    [SupportUser, InviteSupportUserForm].include?(record.class)
  end
end
