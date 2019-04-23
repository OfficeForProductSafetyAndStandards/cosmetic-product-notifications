class User < Shared::Web::User
  has_many :notification_files, dependent: :destroy
  has_many :responsible_person_users, dependent: :destroy
  has_many :responsible_persons, through: :responsible_person_users

  has_one :user_attributes, dependent: :destroy

  # Getters and setters for each UserAttributes column should be added here so they can be accessed directly via delegation.
  delegate :has_accepted_declaration?, :has_accepted_declaration!, to: :get_user_attributes

  def self.find_or_create(user)
    User.find_by(id: user[:id]) || User.create(user.except(:groups))
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

private

  def get_user_attributes
    UserAttributes.find_or_create_by(user_id: id)
  end
end
