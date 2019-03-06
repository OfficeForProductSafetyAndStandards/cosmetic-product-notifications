class User < Shared::Web::User
  has_many :notification_files, dependent: :destroy
  has_many :responsible_person_users, dependent: :destroy
  has_many :responsible_persons, through: :responsible_person_users

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
end
