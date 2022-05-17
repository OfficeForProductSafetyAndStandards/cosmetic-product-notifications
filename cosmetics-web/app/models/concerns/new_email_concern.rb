module NewEmailConcern
  extend ActiveSupport::Concern

  def new_email_pending_confirmation!(email)
    update!(
      new_email: email,
      new_email_confirmation_token: SecureRandom.uuid,
      new_email_confirmation_token_expires_at: Time.zone.now + User::NEW_EMAIL_TOKEN_VALID_FOR.seconds,
    )
    send_new_email_confirmation_email
  end

  def confirm_new_email!
    return if new_email.blank?

    update!(
      email: new_email,
      new_email: nil,
      new_email_confirmation_token: nil,
      new_email_confirmation_token_expires_at: nil,
    )
  end

  class_methods do
    def confirm_new_email!(token)
      user = User.where("new_email_confirmation_token_expires_at > ?", Time.zone.now).find_by! new_email_confirmation_token: token

      old_email = user.email
      user.confirm_new_email!
      NotifyMailer.get_mailer(user).update_email_address_notification_email(user, old_email).deliver_later
    rescue ActiveRecord::RecordNotFound
      raise ArgumentError
    end
  end
end
