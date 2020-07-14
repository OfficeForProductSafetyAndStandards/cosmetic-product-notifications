module FormHelper
  def email_input(user)
    options = {
      id: "email",
      name: "user[email]",
      type: "email",
      classes: "app-!-max-width-two-thirds",
      label: { text: "Email address" },
      errorMessage: format_errors_for(user, user.errors.full_messages_for(:email)),
      value: user.email
    }

    render "components/govuk_input", options
  end

  def password_input(user, options = {})
    options.reverse_merge!(
      id: "password",
      name: "user[password]",
      type: "password",
      classes: "app-!-max-width-two-thirds",
      label: { text: "Password" },
      errorMessage: format_errors_for(user, user.errors.full_messages_for(:password))
    )

    render "components/govuk_input", options
  end

  private

  def format_errors_for(user, errors_for_field)
    return base_errors if user.errors.include?(:base)
    return             if errors_for_field.empty?

    { text: errors_for_field.to_sentence(last_word_connector: " and ") }
  end

  def base_errors
    { text: errors.full_messages_for(:base).to_sentence(last_word_connector: " and ") }
  end
end
