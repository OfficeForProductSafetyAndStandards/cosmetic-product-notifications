class User < Shared::Web::User
  has_many :team_members, dependent: :destroy
  has_many :notification_files, dependent: :destroy
  has_many :responsible_persons, through: :team_members
end
