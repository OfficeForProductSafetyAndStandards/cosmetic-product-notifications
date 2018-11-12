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

    config.exceptions_app = self.routes

    # This is the requests' timeout value in seconds. 15 is the default set by Slowpoke
    # Dev environments need longer due to occasional asset compilation
    Slowpoke.timeout = Rails.env.production? ? 15 : 120
  end
end
