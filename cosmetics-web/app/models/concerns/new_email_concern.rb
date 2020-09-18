module NewEmailConcern
  extend ActiveSupport::Concern

  def new_email=(email)
    if email.present?
      token = SecureRandom.uuid
      self.new_email_confirmation_token = token
      self.new_email_confirmation_token_expires_at = Time.now.utc + User::NEW_EMAIL_TOKEN_VALID_FOR.seconds
    end
    super(email)
  end

  class_methods do
    def new_email!(token)
      user = User.where("new_email_confirmation_token_expires_at > ?", Time.now.utc).find_by! new_email_confirmation_token: token

      user.email = user.new_email
      user.new_email = nil
      user.new_email_confirmation_token = nil
      user.new_email_confirmation_token_expires_at = nil
      user.save!
    rescue ActiveRecord::RecordNotFound
      raise ArgumentError
    end
  end
end
