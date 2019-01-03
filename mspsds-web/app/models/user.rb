class User < Shared::Web::User
  has_many :activities, dependent: :nullify
  has_many :investigations, dependent: :nullify, foreign_key: "assignee_id", inverse_of: :user
  has_many :user_sources, dependent: :delete

  def has_role?(role)
    Shared::Web::KeycloakClient.instance.has_role? role
  end

  def self.get_assignees_select_options(except_those_users = [])
    select_options = { '': nil }

    (self.all - (except_those_users || [])).each do |user|
      display_string = user.get_assignee_display_string
      select_options[display_string] = user.id
    end
    select_options
  end

  def self.get_assignees_select_options_short(except_those_users = [])
    select_options = { '': nil }
    (self.all - (except_those_users || [])).each do |user|
      display_string = user.full_name
      select_options[display_string] = user.id
    end
    select_options
  end

  def get_assignee_display_string
    "#{full_name} (#{email})"
  end
end
