# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.rails_activesupport_breadcrumbs = true

  Sentry.init do |config|
    config.breadcrumbs_logger = [:active_support_logger] # Inject Sentry logger breadcrumbs
    config.dsn = ENV["SENTRY_DSN"]
    config.send_default_pii = false

    config.before_send = lambda do |event, hint|
      return if hint[:exception].is_a?(Pundit::NotAuthorizedError)

      event
    end
  end
end
