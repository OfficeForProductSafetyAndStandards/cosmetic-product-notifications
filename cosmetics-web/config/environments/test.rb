require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Turn false under Spring and add config.action_view.cache_template_loading = true.
  config.cache_classes = true

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a continuous integration
  # system, or in some way before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}",
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Avoid file attachment errors with rails 7 and rack-test.
  # References:
  # - https://stackoverflow.com/questions/71366018/rails-system-test-w-capybara-racktest-raises-activesupportmessageverifierin
  # - https://github.com/rack/rack-test/pull/278
  config.active_storage.multiple_file_field_include_hidden = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  config.active_job.queue_adapter = :inline
  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  config.action_controller.default_url_options = {
    host: ENV["HTTP_HOST"] || "localhost",
    port: ENV["HTTP_PORT"] || 3003,
  }
  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Url for mailer
  config.action_mailer.default_url_options = { host: ENV["SUBMIT_HOST"] }
  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true
end
