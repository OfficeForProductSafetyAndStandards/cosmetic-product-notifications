require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require_relative "../lib/formatters/asim_formatter"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cosmetics
  class Application < Rails::Application
    config.active_record.query_log_tags_enabled = true
    config.active_record.query_log_tags = [
      # Rails query log tags:
      :application,
      :controller,
      :action,
      :job,
      # GraphQL-Ruby query log tags:
      { current_graphql_operation: -> { GraphQL::Current.operation_name },
        current_graphql_field: -> { GraphQL::Current.field&.path },
        current_dataloader_source: -> { GraphQL::Current.dataloader_source_class } },
    ]
    config.time_zone = "Europe/London"

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # vips 8.6+ is the minimum required version to use vips as an variant
    # processor
    # Because GOV.UK PaaS is currently tied to Ubuntu 18, there is no apt
    # package available for this, so we need to use mini_magick for now
    config.active_storage.variant_processor = :mini_magick

    config.eager_load_paths << Rails.root.join("presenters")
    config.eager_load_paths << Rails.root.join("services")

    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = "cosmetics-mailers"

    config.exceptions_app = routes

    # Enable ASIM logging if ENABLE_ASIM_LOGGER is set to 'true'
    if ENV["ENABLE_ASIM_LOGGER"] == "true"
      config.lograge.enabled = true
      config.lograge.formatter = Formatters::AsimFormatter.new
      config.logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))
      config.log_tags = JsonTaggedLogger::LogTagsConfig.generate(
        :request_id,
        :remote_ip,
        JsonTaggedLogger::TagFromSession.get(:user_id),
        :user_agent,
      )
    else
      # normal development logging configuration
      config.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new($stdout))
    end

    config.action_dispatch.rescue_responses["Pundit::NotAuthorizedError"] = :forbidden

    config.antivirus_url = ENV.fetch("ANTIVIRUS_URL", "http://localhost:3006/safe")
    config.search_notify_api_key = ENV.fetch("SEARCH_NOTIFY_API_KEY", "")
    config.submit_notify_api_key = ENV.fetch("NOTIFY_API_KEY", "")
    config.support_notify_api_key = ENV.fetch("SUPPORT_NOTIFY_API_KEY", "")
    config.secondary_authentication_enabled = ENV.fetch("TWO_FACTOR_AUTHENTICATION_ENABLED", "true") == "true"
    config.two_factor_attempts = 10
    config.whitelisted_direct_otp_code = ENV["WHITELISTED_DIRECT_OTP_CODE"]
    config.whitelisted_time_otp_code = ENV["WHITELISTED_TIME_OTP_CODE"]
    config.vcap_application = ENV["VCAP_APPLICATION"]
    config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"

    config.active_storage.resolve_model_to_route = :rails_storage_proxy

    # Avoid sassc-rails errors when compressing CSS.
    # See https://github.com/alphagov/govuk-frontend/issues/1350
    config.assets.css_compressor = nil
    config.sass.style = :compressed

    # Avoid file attachment errors with blank params
    config.active_storage.multiple_file_field_include_hidden = false

    # Use SHA1 for key generator to avoid errors when decrypting secrets generated prior to Rails 7 (new default is SHA256)
    config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA1
  end
end
