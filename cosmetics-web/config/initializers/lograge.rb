# Be sure to restart your server when you modify this file.

Rails.application.configure do
  if Rails.env.production?
    config.lograge.enabled = ENV.fetch("LOGRAGE_ENABLED", "true") == "true"

    config.lograge.custom_payload do |_controller|
      extra_payload = {}
      extra_payload[:user_id] = User.current&.id
      extra_payload
    end
  end
end
