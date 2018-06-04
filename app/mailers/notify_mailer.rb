require "notifications/client"

class NotifyMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers

  def initialize
    @client = Notifications::Client.new(ENV["NOTIFY_API_KEY"])
  end

  def reset_password_instructions(user, token, _opts = {})
    # Send emails via notify
    @client.send_email(
      email_address: user.email,
      template_id: "e85c3c6c-272d-4c43-b8fb-e7d266bc2bd9",
      personalisation: {
        name: user.email,
        reset_url: edit_password_url(user, reset_password_token: token)
      },
      reference: "Password reset"
    )
  end
end
