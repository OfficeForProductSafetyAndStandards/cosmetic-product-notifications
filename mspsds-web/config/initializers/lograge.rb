# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.custom_payload do |controller|
    extra_payload = {}
    extra_payload[:user_id] = controller.current_user.id if controller.respond_to?(:user_signed_in?) && controller.current_user
    extra_payload
  end
end
