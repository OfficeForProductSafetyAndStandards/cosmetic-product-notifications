Rails.application.configure do
  config.hosts.clear

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Enable server timing
  config.server_timing = true

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # For Devise
  config.action_controller.default_url_options = { host: "localhost", port: ENV.fetch("PORT", "3000") }

  # Url for mailer
  config.action_mailer.default_url_options = { host: "localhost", port: ENV.fetch("PORT", "3000") }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  if ENV["DIRECT_UPLOAD_DOMAIN"]
    config.action_controller.default_url_options = { host: ENV["DIRECT_UPLOAD_DOMAIN"], port: ENV.fetch("PORT", "3000") }
  end

  config.active_record.verbose_query_logs = true
  config.slowpoke.timeout = 90
end
