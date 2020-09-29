class SubmitUser < User
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable

  belongs_to :organisation

  has_many :notification_files, dependent: :destroy
  has_many :responsible_person_users, dependent: :destroy, foreign_key: :user_id, inverse_of: :user
  has_many :responsible_persons, through: :responsible_person_users

  has_one :user_attributes, dependent: :destroy
  validates :mobile_number, presence: true

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
    return true if !account_security_completed && self.persisted?

    super
  end

  def responsible_persons
    # ActiveHash does not support has_many through: associations
    # Therefore adopt the workaround suggested here: https://github.com/zilkey/active_hash/issues/25
    ResponsiblePerson.find responsible_person_users.map(&:responsible_person_id)
  end

  def poison_centre_user?
    false
  end

  def msa_user?
    false
  end

  def can_view_product_ingredients?
    !msa_user? # Could hardcode "true" but leave it as original for User for clarity
  end

  def send_confirmation_instructions
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

  def mobile_number_change_allowed?
    !mobile_number_verified?
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
