class SubmitUser < User
  ALLOW_INTERNATIONAL_PHONE_NUMBER = true
  TOTP_ISSUER = "Submit Cosmetics".freeze

  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable, :session_limitable

  belongs_to :organisation

  has_many :responsible_person_users, dependent: :destroy, foreign_key: :user_id, inverse_of: :user
  has_many :responsible_persons, through: :responsible_person_users
  has_many :pending_responsible_person_users, dependent: :destroy, foreign_key: :inviting_user_id, inverse_of: :inviting_user

  has_one :user_attributes, dependent: :destroy, foreign_key: :user_id, inverse_of: :user

  validates :mobile_number,
            phone: { message: :invalid, allow_international: ALLOW_INTERNATIONAL_PHONE_NUMBER },
            if: -> { mobile_number.present? }

  def self.confirm_by_token(token)
    user = super(token)
    user.persisted? ? user : nil
  end

  def self.find_user_by_confirmation_token!(confirmation_token)
    new_user = SubmitUser.find_by!(confirmation_token: confirmation_token)

    if new_user.send(:confirmation_period_expired?)
      new_user.resend_confirmation_instructions
      raise ActiveRecord::RecordInvalid
    end
    new_user
  end

  def active_for_authentication?
    return true if !account_security_completed && persisted?

    super
  end

  def poison_centre_user?
    false
  end

  def msa_user?
    false
  end

  def opss_science_user?
    false
  end

  def can_view_product_ingredients?
    !msa_user? # Could hardcode "true" but leave it as original for User for clarity
  end

  def dont_send_confirmation_instructions!
    @dont_send_confirmation_instructions = true
  end

  def resend_account_setup_link
    resend_confirmation_instructions
  end

  def send_confirmation_instructions
    return if @dont_send_confirmation_instructions

    unless @raw_confirmation_token
      generate_confirmation_token!
    end

    SubmitNotifyMailer.send_account_confirmation_email(self).deliver_later
  end

  def send_reset_password_instructions_notification(token)
    SubmitNotifyMailer.reset_password_instructions(self, token).deliver_later
  end

  # Don't reset password attempts yet, it will happen on next successful login
  def unlock_access!
    self.locked_at = nil
    self.unlock_token = nil
    save(validate: false)
  end

  def regenerate_confirmation_token_if_expired; end

private

  # Devise::Models::Lockable

  def send_unlock_instructions
    raw, enc = Devise.token_generator.generate(self.class, :unlock_token)
    self.unlock_token = enc
    save(validate: false)
    reset_password_token = set_reset_password_token
    SubmitNotifyMailer.account_locked(
      self,
      unlock_token: raw,
      reset_password_token: reset_password_token,
    ).deliver_later
    raw
  end

  def get_user_attributes
    UserAttributes.find_or_create_by(user_id: id)
  end
end
