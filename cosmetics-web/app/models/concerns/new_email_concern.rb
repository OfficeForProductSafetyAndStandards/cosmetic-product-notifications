module NewEmailConcern
  extend ActiveSupport::Concern

  def new_email_pending_confirmation!(email)
    ActiveRecord::Base.transaction do
      self.new_email_confirmation_token = SecureRandom.uuid
      self.new_email_confirmation_token_expires_at = Time.zone.now + User::NEW_EMAIL_TOKEN_VALID_FOR.seconds
      self.new_email = email
      save!
      send_new_email_confirmation_email
    end
  end

  class_methods do
    def confirm_new_email!(token)
      user = User.where("new_email_confirmation_token_expires_at > ?", Time.zone.now).find_by! new_email_confirmation_token: token

      old_email = user.email
      user.email = user.new_email
      user.new_email = nil
      user.new_email_confirmation_token = nil
      user.new_email_confirmation_token_expires_at = nil
      ActiveRecord::Base.transaction do
        user.save!
        NotifyMailer.get_mailer(user).update_email_address_notification_email(user, old_email).deliver_later
      end
    rescue ActiveRecord::RecordNotFound
      raise ArgumentError
    end
  end
end
