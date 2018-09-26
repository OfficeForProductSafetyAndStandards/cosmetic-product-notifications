require "notifications/client"

# Send emails via notify
class NotifyMailer < ApplicationMailer
  def initialize
    @client = Notifications::Client.new(ENV["NOTIFY_API_KEY"])
  end

  def assigned_investigation(investigation, user)
    @client.send_email(
      email_address: user.email,
      template_id: "b8260d95-84f8-4f45-928e-7916d27b5a80",
      personalisation: {
        name: user.email,
        investigation_url: investigation_url(investigation)
      },
      reference: "Investigation assigned"
    )
  end
end
