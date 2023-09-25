class User < ApplicationRecord
  NAME_MAX_LENGTH = 50
  NEW_EMAIL_TOKEN_VALID_FOR = 600 # 10 minutes
  SECONDARY_AUTHENTICATION_METHODS = %w[app sms].freeze

  include Encryptable
  include NewEmailConcern

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable,
         :lockable,
         :timeoutable,
         :trackable,
         :session_limitable

  attribute :old_password, :string
  attribute :invite, :boolean

  attr_encrypted :totp_secret_key

  validates :email, presence: true
  validate  :email_not_pending_change_for_other_user
  validates :new_email, email: { message: :invalid, allow_nil: true }
  validates :new_email, uniqueness: true, allow_nil: true

  validate  :new_email_not_registered

  validates :password, common_password: true

  validates :name, presence: true, unless: -> { invite }
  validates :name, length: { maximum: NAME_MAX_LENGTH }, user_name_format: true, if: :name_changed?

  with_options if: :account_security_completed do
    validate :secondary_authentication_methods_presence
    validate :secondary_authentication_methods_allowed, if: -> { secondary_authentication_methods&.any? }
  end

  before_validation :update_secondary_authentication_methods, if: :secondary_authentication_info_will_change?
  before_save :ensure_mobile_number_verification, if: :will_save_change_to_mobile_number?

  def send_new_email_confirmation_email
    mailer.new_email_verification_email(self).deliver_later
  end

  def mobile_number_verified?
    if Rails.configuration.secondary_authentication_enabled
      super
    else
      true
    end
  end

  def mobile_number_change_allowed?
    !mobile_number_verified?
  end

  def mobile_number_pending_verification?
    mobile_number.present? && !mobile_number_verified?
  end

  def has_completed_registration?
    account_security_completed? && secondary_authentication_set?
  end

  def totp_issuer
    self.class::TOTP_ISSUER
  end

  def sms_authentication_set?
    mobile_number.present? && mobile_number_verified?
  end

  def app_authentication_set?
    encrypted_totp_secret_key.present? && last_totp_at.present?
  end

  def multiple_secondary_authentication_methods?
    secondary_authentication_methods.size > 1
  end

  def reset_secondary_authentication!
    update(mobile_number: nil,
           mobile_number_verified: false,
           direct_otp: nil,
           direct_otp_sent_at: nil,
           encrypted_totp_secret_key: nil,
           last_totp_at: nil,
           last_recovery_code_at: nil,
           secondary_authentication_methods: nil,
           secondary_authentication_recovery_codes_generated_at: nil,
           secondary_authentication_recovery_codes: [],
           secondary_authentication_recovery_codes_used: [],
           account_security_completed: false)
    send_reset_password_instructions
  end

  def uses_email_address?(email_address)
    return false if email_address.blank?

    email.casecmp(email_address).zero? || (new_email.present? && new_email.casecmp(email_address).zero?)
  end

  def mailer
    NotifyMailer.get_mailer(self)
  end

  # Overwrites Devise::Models::Lockable#send_unlock_instructions
  def send_unlock_instructions
    raw, enc = Devise.token_generator.generate(self.class, :unlock_token)
    self.unlock_token = enc
    save(validate: false)
    reset_password_token = set_reset_password_token
    mailer.account_locked(self, unlock_token: raw, reset_password_token:).deliver_later
    raw
  end

  # Overwrites Devise::Models::Lockable#unlock_access!
  # Don't reset password attempts yet, it will happen on next successful login
  def unlock_access!
    self.locked_at = nil
    self.unlock_token = nil
    save(validate: false)
  end

  # Used by Devise to ensure deactivated users cannot sign in
  def active_for_authentication?
    super && deactivated_at.blank?
  end

  def inactive_message
    I18n.t("users.deactivated") if deactivated?
  end

  def deactivated?
    deactivated_at.present?
  end

  # Use the `email` when targeting feature flags
  def flipper_id
    email
  end

private

  # Overwrites Devise::Models::Recoverable#send_reset_password_instructions_notification
  def send_reset_password_instructions_notification(token)
    mailer.reset_password_instructions(self, token).deliver_later
  end

  def secondary_authentication_set?
    !mobile_number_pending_verification? && (sms_authentication_set? || app_authentication_set?)
  end

  def email_not_pending_change_for_other_user
    if email.present? && self.class.where(new_email: email).where.not(id:).any?
      errors.add(:email, :taken)
    end
  end

  def new_email_not_registered
    if new_email.present? && self.class.find_by(email: new_email).present?
      errors.add(:new_email, :taken)
    end
  end

  def secondary_authentication_methods_presence
    if !secondary_authentication_methods.is_a?(Array) || secondary_authentication_methods.empty?
      errors.add(:secondary_authentication_methods, :blank)
    end
  end

  def secondary_authentication_methods_allowed
    unless secondary_authentication_methods.all? { |method| SECONDARY_AUTHENTICATION_METHODS.include?(method) }
      errors.add(:secondary_authentication_methods, :invalid)
    end
  end

  def ensure_mobile_number_verification
    return if will_save_change_to_mobile_number_verified? # E.G: Manually set on spec factory

    self.mobile_number_verified = false
  end

  def secondary_authentication_info_will_change?
    will_save_change_to_mobile_number? || will_save_change_to_encrypted_totp_secret_key?
  end

  def update_secondary_authentication_methods
    methods = []
    methods << "app" if encrypted_totp_secret_key.present?
    methods << "sms" if mobile_number.present?

    self.secondary_authentication_methods = methods
  end
end
