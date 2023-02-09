class SearchUser < User
  include Privileges::SearchConcern

  INVITATION_EXPIRATION_DAYS = 14
  ALLOW_INTERNATIONAL_PHONE_NUMBER = false
  TOTP_ISSUER = "Search Cosmetics".freeze

  # Include default devise modules. Others available are:
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         :lockable, :trackable, :session_limitable

  belongs_to :organisation

  has_one :user_attributes, dependent: :destroy, foreign_key: :user_id, inverse_of: :user
  attribute :skip_password_validation, :boolean, default: false

  enum role: {
    poison_centre: "poison_centre",
    msa: "market_surveilance_authority", # Remove once all MSA users have been migrated
    opss_general: "opss_general",
    opss_enforcement: "opss_enforcement",
    opss_science: "opss_science",
    trading_standards: "trading_standards",
  }

  validates :mobile_number,
            phone: { message: :invalid, allow_international: ALLOW_INTERNATIONAL_PHONE_NUMBER },
            if: -> { mobile_number.present? }

  def resend_account_setup_link
    SearchNotifyMailer.invitation_email(self).deliver_later
  end

  def send_reset_password_instructions_notification(token)
    SearchNotifyMailer.reset_password_instructions(self, token).deliver_later
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

private

  # Devise::Models::Lockable

  def send_unlock_instructions
    raw, enc = Devise.token_generator.generate(self.class, :unlock_token)
    self.unlock_token = enc
    save(validate: false)
    reset_password_token = set_reset_password_token
    SearchNotifyMailer.account_locked(
      self,
      unlock_token: raw,
      reset_password_token:,
    ).deliver_later
    raw
  end

  def get_user_attributes
    UserAttributes.find_or_create_by(user_id: id)
  end
end
