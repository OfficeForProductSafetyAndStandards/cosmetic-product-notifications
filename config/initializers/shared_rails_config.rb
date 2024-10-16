# Rails cleverly surrounds fields with validation errors with a div that changes how they look
# Sadly it is not Digital Service Standard compliant, so we prevent it here
Rails.application.config.action_view.field_error_proc = proc do |html_tag, _|
  html_tag
end

Rails.application.config.action_view.form_with_generates_ids = true
