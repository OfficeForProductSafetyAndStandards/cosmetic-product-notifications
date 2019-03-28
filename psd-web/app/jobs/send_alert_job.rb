class SendAlertJob < ApplicationJob
  def perform(email_addresses, email_subject, email_body)
    email_addresses.each do |email_address|
      NotifyMailer.alert(
        email_address,
        email_body,
        email_subject
      ).deliver_later
    end
  end
end
