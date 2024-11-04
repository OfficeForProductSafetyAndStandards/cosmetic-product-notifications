# frozen_string_literal: true

Devise.setup do |config|
  config.lock_strategy = :failed_attempts
  config.unlock_strategy = :email
  config.maximum_attempts = if Rails.env.test?
                              2
                            else
                              ENV.fetch("LOCK_MAXIMUM_ATTEMPTS", 10).to_i
                            end

  config.mailer_sender = "please-change-me-at-config-initializers-devise@example.com"

  require "devise/orm/active_record"

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 12

  config.confirm_within = 4.hours
  config.reconfirmable = false

  config.expire_all_remember_me_on_sign_out = true
  config.rememberable_options = { secure: Rails.env.production?, httponly: true }

  config.password_length = 8..128
  config.email_regexp = URI::MailTo::EMAIL_REGEXP
  config.timeout_in = 3.hours

  config.reset_password_within = 72.hours

  config.sign_out_via = :delete

  config.warden do |manager|
    manager.failure_app = CustomFailureApp
  end
end
