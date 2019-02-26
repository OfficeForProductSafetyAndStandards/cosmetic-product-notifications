class SendAlertJob < ApplicationJob
  def self.perform(email_subject, email_body)
    User.all.each do |user|
      NotifyMailer.alert(
        user.full_name,
        user.email,
        email_body,
        email_subject
      ).deliver_later
    end
  end
end
