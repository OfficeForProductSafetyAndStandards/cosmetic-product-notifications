class SendAlertJob < ApplicationJob
  def perform(email_addresses, subject_text:, body_text:)
    email_addresses.each do |email_address|
      NotifyMailer.alert(
        email_address,
        subject_text: subject_text,
        body_text: body_text
      ).deliver_later
    end
  end
end
