require_relative "boot"

require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ProductSafetyDatabase
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.eager_load_paths << Rails.root.join("presenters")

    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = 'psd-mailers'

    # This changes Rails timezone, but keeps ActiveRecord in UTC
    config.time_zone = "Europe/London"

    # Set the request timeout in seconds. The default set by Slowpoke is 15 seconds.
    # Use a longer timeout on development environments to allow for asset compilation.
    config.slowpoke.timeout = Rails.env.production? ? 15 : 180

    config.exceptions_app = self.routes
    config.action_dispatch.rescue_responses["Pundit::NotAuthorizedError"] = :forbidden
  end
end
