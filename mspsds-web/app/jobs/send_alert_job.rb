class SendAlertJob < ApplicationJob
  def perform(recipients_details, email_subject, email_body)
    recipients_details.each do |details|
      NotifyMailer.alert(
        details[:full_name],
        details[:email],
        email_body,
        email_subject
      ).deliver_later
    end
  end
end
