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

  def has_completed_registration?
    encrypted_password.present? && name.present? && mobile_number.present? && mobile_number_verified
  end

private

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
end
