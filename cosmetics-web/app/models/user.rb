class User < Shared::Web::User
  has_many :responsible_person_users, dependent: :destroy
  has_many :responsible_persons, through: :responsible_person_users

  def self.find_or_create(user)
    User.find_by(id: user[:id]) || User.create(user.except(:groups))
  end

  def responsible_persons
    ResponsiblePerson.find responsible_person_users.map(&:responsible_person_id)
  end
end
