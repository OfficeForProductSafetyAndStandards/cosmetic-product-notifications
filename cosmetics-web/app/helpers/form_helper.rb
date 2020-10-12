module FormHelper
  def form_input(user, field, options = {})
    value = user[field]
    field = field.to_s
    options.reverse_merge!(
      id: field,
      name: "#{resource_form_name(user)}[#{field}]",
      type: "text",
      classes: "app-!-max-width-two-thirds",
      label: { text: user.class.human_attribute_name(field.to_sym) },
      errorMessage: format_errors_for(user, user.errors.full_messages_for(field)),
      value: value,
    )

    render "components/govuk_input", options
  end

  def email_input(user)
    options = {
      id: "email",
      name: "#{resource_form_name(user)}[email]",
      type: "email",
      classes: "app-!-max-width-two-thirds",
      label: { text: "Email address" },
      errorMessage: format_errors_for(user, user.errors.full_messages_for(:email)),
      value: user.email,
    }

    render "components/govuk_input", options
  end

  def password_input(user, options = {})
    options.reverse_merge!(
      id: "password",
      name: "#{resource_form_name(user)}[password]",
      type: "password",
      classes: "app-!-max-width-two-thirds",
      label: { text: "Password" },
      errorMessage: format_errors_for(user, user.errors.full_messages_for(:password)),
    )

    render "components/govuk_input", options
  end

  def password_confirmation_input(user, options = {})
    options.reverse_merge!(
      id: "password_confirmation",
      name: "#{resource_form_name(user)}[password_confirmation]",
      type: "password",
      classes: "app-!-max-width-two-thirds",
      label: { text: "Password confirmation" },
      errorMessage: format_errors_for(user, user.errors.full_messages_for(:password_confirmation)),
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

  def resource_form_name(resource_object)
    ActiveModel::Naming.param_key(resource_object.class)
  end
end
