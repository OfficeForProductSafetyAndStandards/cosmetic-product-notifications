require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.eager_load_paths << Rails.root.join("presenters")

    # Rails cleverly surrounds fields with validation errors with a div that changes how they look
    # Sadly it is not Digital Service Standard compliant, so we prevent it here
    config.action_view.field_error_proc = Proc.new { |html_tag, _|
      html_tag
    }
    config.action_view.form_with_generates_ids = true

    # This changes Rails timezone, but keeps ActiveRecord in UTC
    config.time_zone = "Europe/London"

    # Setup sentry (from https://github.com/getsentry/raven-ruby/blob/369fe6c5e2389b8c13b71e47d688a719e5c20df7/examples/rails-5.0/config/application.rb)
    config.rails_activesupport_breadcrumbs = true

    config.exceptions_app = self.routes

    require 'raven/breadcrumbs/logger'

    Raven.configure do |config|
      config.dsn = ENV['SENTRY_DSN']
      config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    end

    # This is the requests' timeout value in seconds. 15 is the default set by Slowpoke
    # Dev environments need longer due to occasional asset compilation
    Slowpoke.timeout = Rails.env.production? ? 15 : 180
  end
end
