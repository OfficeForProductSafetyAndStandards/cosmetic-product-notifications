# Rails cleverly surrounds fields with validation errors with a div that changes how they look
# Sadly it is not Digital Service Standard compliant, so we prevent it here
Rails.application.config.action_view.field_error_proc = Proc.new { |html_tag, _|
  html_tag
}

Rails.application.config.action_view.form_with_generates_ids = true

ActionView::Base.send :include, Shared::Web::ComponentsHelper
