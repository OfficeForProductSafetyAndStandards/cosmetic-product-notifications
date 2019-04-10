Rails.application.config.after_initialize do
  unless Rails.env.test? || Sidekiq.server?
    # Load teams and team membership on app startup
    Team.load
    TeamUser.load
  end
end
