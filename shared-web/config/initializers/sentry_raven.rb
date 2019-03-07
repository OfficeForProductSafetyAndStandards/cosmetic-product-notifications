# Be sure to restart your server when you modify this file.
# Setup Sentry (from https://github.com/getsentry/raven-ruby/blob/master/examples/rails-5.0/config/application.rb)

Rails.application.configure do
  config.rails_activesupport_breadcrumbs = true

  # Inject Sentry logger breadcrumbs
  require "raven/breadcrumbs/logger"

  Raven.configure do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  end
end
