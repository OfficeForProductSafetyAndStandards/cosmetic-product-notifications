class User < ApplicationRecord
  NEW_EMAIL_TOKEN_VALID_FOR = 600 # 10 minutes
  SECONDARY_AUTHENTICATION_METHODS = %w[app sms].freeze

  include Encryptable
  include NewEmailConcern
  validates :email, presence: true

  attribute :old_password, :string
  attribute :invite, :boolean

  attr_encrypted :totp_secret_key

  validates :new_email, email: { message: :invalid, allow_nil: true }
  validates :name, presence: true, unless: -> { invite }

  with_options if: :account_security_completed do
    validate :secondary_authentication_methods_presence
    validate :secondary_authentication_methods_allowed, if: -> { secondary_authentication_methods&.any? }
  end

  before_validation :update_secondary_authentication_methods, if: :secondary_authentication_info_will_change?
  before_save :ensure_mobile_number_verification, if: :will_save_change_to_mobile_number?

  def send_new_email_confirmation_email
    NotifyMailer.get_mailer(self).new_email_verification_email(self).deliver_later
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

private

  def secondary_authentication_set?
    !mobile_number_pending_verification? && (sms_authentication_set? || app_authentication_set?)
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
