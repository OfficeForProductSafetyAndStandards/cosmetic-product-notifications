# Be sure to restart your server when you modify this file.

# Sidekiq won't have access to the session store, so we shouldn't initialise the connection here
unless Sidekiq.server?
  Rails.application.config.session_store :redis_store,
                                         servers: Rails.application.config_for(:redis_session),
                                         key: "_psd_session"
end
