class TeamUser < Shared::Web::TeamUser
end
TeamUser.all if Rails.env.development?
