class SearchUser < User
  INVITATION_EXPIRATION_DAYS = 14

  # Include default devise modules. Others available are:
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         :lockable, :trackable

  belongs_to :organisation

  has_one :user_attributes, dependent: :destroy
  attribute :skip_password_validation, :boolean, default: false

  enum role: {
    poison_centre: "poison_centre",
    msa: "market_surveilance_authority",
  }

  def poison_centre_user?
    poison_centre?
  end

  def msa_user?
    msa?
  end

  def can_view_product_ingredients?
    !msa_user?
  end

  def send_confirmation_instructions
    NotifyMailer.send_account_confirmation_email(self).deliver_later
  end

  def send_reset_password_instructions_notification(token)
    NotifyMailer.reset_password_instructions(self, token).deliver_later
  end

  # Don't reset password attempts yet, it will happen on next successful login
  def unlock_access!
    self.locked_at = nil
    self.unlock_token = nil
    save(validate: false)
  end

  def password_required?
    return false if skip_password_validation

    super
  end

  def invitation_expired?
    invited_at <= INVITATION_EXPIRATION_DAYS.days.ago
  end

  def has_completed_registration?
    encrypted_password.present? && name.present? && mobile_number.present? && mobile_number_verified
  end

  def mobile_number_change_allowed?
    !mobile_number_verified?
  end

private

  # Devise::Models::Lockable

  def send_unlock_instructions
    raw, enc = Devise.token_generator.generate(self.class, :unlock_token)
    self.unlock_token = enc
    save(validate: false)
    reset_password_token = set_reset_password_token
    NotifyMailer.account_locked(
      self,
      unlock_token: raw,
      reset_password_token: reset_password_token,
    ).deliver_later
    raw
  end

  def increment_failed_attempts
    # TODO:
    # return unless mobile_number_verified?

    super
  end

  def get_user_attributes
    UserAttributes.find_or_create_by(user_id: id)
  end
end
