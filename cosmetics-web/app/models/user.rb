class User < ApplicationRecord
  NEW_EMAIL_TOKEN_VALID_FOR = 600 # 10 minutes

  include NewEmailConcern

  attribute :old_password, :string
  attribute :invite, :boolean

  validates :new_email, email: { allow_nil: true }
  validates :name, presence: true, unless: -> { invite }

  def send_new_email_confirmation_email
    NotifyMailer.new_email_verification_email(self).deliver_later
  end
end
