return if Sidekiq.server?

OkComputer.mount_at = ENV["HEALTH_CHECK_USERNAME"].present? && ENV["HEALTH_CHECK_PASSWORD"].present? && "health"
OkComputer.require_authentication(ENV["HEALTH_CHECK_USERNAME"], ENV["HEALTH_CHECK_PASSWORD"])

OkComputer::Registry.register "elasticsearch", OkComputer::ElasticsearchCheck.new(Rails.application.config_for(:elasticsearch)[:url])
OkComputer::Registry.register "redis", OkComputer::RedisCheck.new(Rails.application.config_for(:redis))
OkComputer::Registry.register "sidekiq", OkComputer::SidekiqLatencyCheck.new(30)
OkComputer::Registry.register "keycloak", KeycloakCheck.new

class KeycloakCheck < OkComputer::Check
  def check
    begin
      users = Keycloak::Internal.get_users
      mark_message "Successfully fetched #{JSON.parse(users).length} users"
    rescue StandardError => e
      mark_failure
      mark_message "Failed to fetch users from Keycloak: #{e.message}"
    end
  end
end
