class User < Shared::Web::User
  has_many :team_members, dependent: :destroy
  has_many :responsible_persons, through: :team_members

  def self.find_or_create(user)
    User.find_by(id: user[:id]) || User.create(user.except(:groups))
  end

  def responsible_persons
    ResponsiblePerson.find team_members.map(&:responsible_person_id)
  end
end
