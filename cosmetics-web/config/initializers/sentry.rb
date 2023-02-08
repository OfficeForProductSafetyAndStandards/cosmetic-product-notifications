# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.rails_activesupport_breadcrumbs = true

  Sentry.init do |config|
    config.breadcrumbs_logger = [:active_support_logger] # Inject Sentry logger breadcrumbs
    config.dsn = ENV["SENTRY_DSN"]
    config.excluded_exceptions += ["Pundit::NotAuthorizedError"]
    config.send_default_pii = false

    if ENV["SENTRY_PERFORMANCE_MONITORING_ENABLED"] == "true"
      # To activate performance monitoring
      # We recommend adjusting the value in production:
      # Originally we set 0.25, tracing 25% of transactions. This reached our Sentry 100k transactions quota in a few hours.
      config.traces_sample_rate = 0.0025 # 0.25% of transactions
    end
  end
end
