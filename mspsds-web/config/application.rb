require_relative "boot"

require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mspsds
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.eager_load_paths << Rails.root.join("presenters")

    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = 'mspsds-mailers'

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
