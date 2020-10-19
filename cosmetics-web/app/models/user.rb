class User < ApplicationRecord
  NEW_EMAIL_TOKEN_VALID_FOR = 600 # 10 minutes

  include NewEmailConcern
  validates :email, presence: true

  attribute :old_password, :string
  attribute :invite, :boolean

  validates :new_email, email: { allow_nil: true }
  validates :name, presence: true, unless: -> { invite }

  def send_new_email_confirmation_email
    NotifyMailer.new_email_verification_email(self).deliver_later
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
end
