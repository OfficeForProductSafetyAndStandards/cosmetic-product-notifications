require "notifications/client"

# Send emails via notify
class NotifyMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers

  def initialize
    @client = Notifications::Client.new(ENV["NOTIFY_API_KEY"])
  end

  def reset_password_instructions(user, token, _opts = {})
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

  def invitation_instructions(user, _token, _opts = {})
    @client.send_email(
      email_address: user.email,
      template_id: "edab6550-eb34-4cb1-910f-41606e583076",
      personalisation: {
        name: user.email,
        invitation_url: accept_user_invitation_url(invitation_token: user.raw_invitation_token)
      },
      reference: "Confirm account"
    )
  end
end
