class SubmitUser < User
  include Privileges::SubmitConcern

  ALLOW_INTERNATIONAL_PHONE_NUMBER = true
  TOTP_ISSUER = "Submit Cosmetics".freeze

  devise :registerable, :confirmable

  has_many :responsible_person_users, dependent: :destroy, foreign_key: :user_id, inverse_of: :user
  has_many :responsible_persons, through: :responsible_person_users
  has_many :pending_responsible_person_users, dependent: :destroy, foreign_key: :inviting_user_id, inverse_of: :inviting_user

  validates :mobile_number,
            phone: { message: :invalid, allow_international: ALLOW_INTERNATIONAL_PHONE_NUMBER },
            if: -> { mobile_number.present? }

  def self.find_user_by_confirmation_token!(confirmation_token)
    new_user = SubmitUser.find_by!(confirmation_token:)

    if new_user.send(:confirmation_period_expired?)
      new_user.resend_confirmation_instructions
      raise ActiveRecord::RecordInvalid
    end
    new_user
  end

  def dont_send_confirmation_instructions!
    @dont_send_confirmation_instructions = true
  end

  def resend_account_setup_link
    resend_confirmation_instructions
  end

  def regenerate_confirmation_token_if_expired; end

  # Overwrites Devise::Models::Confirmable#send_confirmation_instructions
  def send_confirmation_instructions
    return if @dont_send_confirmation_instructions

    unless @raw_confirmation_token
      generate_confirmation_token!
    end

    SubmitNotifyMailer.send_account_confirmation_email(self).deliver_later
  end

  # Overwrites Devise::Models::Confirmable#active_for_authentication?
  def active_for_authentication?
    return true if !account_security_completed && persisted?

    super
  end

  # Overwrites Devise::Models::Confirmable.confirm_by_token
  def self.confirm_by_token(token)
    user = super(token)
    user.persisted? ? user : nil
  end
end
