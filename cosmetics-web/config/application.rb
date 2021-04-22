require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cosmetics
  class Application < Rails::Application
    config.time_zone = "Europe/London"

    # Initialize configuration defaults for originally generated Rails version.
    # config.load_defaults 5.0

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true

    config.eager_load_paths << Rails.root.join("presenters")
    config.eager_load_paths << Rails.root.join("services")

    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = "cosmetics-mailers"

    # Set the request timeout in seconds. The default set by Slowpoke is 15 seconds.
    # Use a longer timeout on development environments to allow for asset compilation.
    # config.slowpoke.timeout = Rails.env.production? ? 15 : 180

    config.exceptions_app = routes
    config.action_dispatch.rescue_responses["Pundit::NotAuthorizedError"] = :forbidden

    config.active_record.belongs_to_required_by_default = true
    config.antivirus_url = ENV.fetch("ANTIVIRUS_URL", "http://localhost:3006/safe")
    config.search_notify_api_key = ENV.fetch("SEARCH_NOTIFY_API_KEY", "")
    config.submit_notify_api_key = ENV.fetch("NOTIFY_API_KEY", "")
    config.secondary_authentication_enabled = ENV.fetch("TWO_FACTOR_AUTHENTICATION_ENABLED", "true") == "true"
    config.two_factor_attempts = 10
    config.whitelisted_2fa_code = ENV["WHITELISTED_2FA_CODE"]
    config.vcap_application = ENV["VCAP_APPLICATION"]
    config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"
  end
end
