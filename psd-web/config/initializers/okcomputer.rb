return if Sidekiq.server?

OkComputer.mount_at = ENV["HEALTH_CHECK_USERNAME"].present? && ENV["HEALTH_CHECK_PASSWORD"].present? && "health"
OkComputer.require_authentication(ENV["HEALTH_CHECK_USERNAME"], ENV["HEALTH_CHECK_PASSWORD"])

OkComputer::Registry.register "elasticsearch", OkComputer::ElasticsearchCheck.new(Rails.application.config_for(:elasticsearch)[:url])
OkComputer::Registry.register "redis-queue", OkComputer::RedisCheck.new(Rails.application.config_for(:redis_queue))
OkComputer::Registry.register "redis-session", OkComputer::RedisCheck.new(Rails.application.config_for(:redis_session))
OkComputer::Registry.register "sidekiq", OkComputer::SidekiqLatencyCheck.new(30)

class KeycloakCheck < OkComputer::Check
  def check
    begin
      users = Keycloak::Internal.get_users
      mark_message "Successfully fetched #{JSON.parse(users).length} users"
    rescue StandardError => error
      mark_failure
      mark_message "Failed to fetch users from Keycloak: #{error.message}"
    end
  end
end

OkComputer::Registry.register "keycloak", KeycloakCheck.new
