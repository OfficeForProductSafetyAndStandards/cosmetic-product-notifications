class SubmitUser < User
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable

  belongs_to :organisation

  has_many :notification_files, dependent: :destroy
  has_many :responsible_person_users, dependent: :destroy, foreign_key: :user_id # TODO: actually, only submit_users has resp person
  has_many :responsible_persons, through: :responsible_person_users

  has_one :user_attributes, dependent: :destroy

  def has_role?(role)
    false # TODO: AFAIK submit users does not have any roles
  end

  def responsible_persons
    # ActiveHash does not support has_many through: associations
    # Therefore adopt the workaround suggested here: https://github.com/zilkey/active_hash/issues/25
    ResponsiblePerson.find responsible_person_users.map(&:responsible_person_id)
  end

  def poison_centre_user?
    has_role? :poison_centre_user
  end

  def msa_user?
    has_role? :msa_user
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
private

  def get_user_attributes
    UserAttributes.find_or_create_by(user_id: id)
  end
end
