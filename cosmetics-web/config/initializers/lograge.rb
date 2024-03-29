# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.lograge.enabled = Rails.env.production?

  config.lograge.custom_payload do |controller|
    extra_payload = {}
    extra_payload[:user_id] = begin
      controller.send(:current_user)&.id
    rescue StandardError
      nil
    end
    extra_payload[:journey_id] = begin
      controller.request.cookies[:journey_id]
    rescue StandardError
      nil
    end
    extra_payload
  end
end
