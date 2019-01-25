class Team < Shared::Web::Team
end
Team.all if Rails.env.development?
