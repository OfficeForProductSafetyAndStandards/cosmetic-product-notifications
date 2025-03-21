require 'cgi'
require 'json'
require 'uri'

def opensearch_url
  if ENV['COPILOT_ENVIRONMENT_NAME'] # DBT Platform
    URI::parse(CGI.unescape(ENV.fetch('OPENSEARCH_URL')))
  else
    # Fallback to the original logic
    ENV["VCAP_SERVICES"] && CF::App::Credentials.find_by_service_name("cosmetics-opensearch-1")["uri"]
  end
end

return if Sidekiq.server?

OkComputer.mount_at = ENV["HEALTH_CHECK_USERNAME"].present? && ENV["HEALTH_CHECK_PASSWORD"].present? && "health"
OkComputer.require_authentication(ENV.fetch("HEALTH_CHECK_USERNAME", "username"), ENV.fetch("HEALTH_CHECK_PASSWORD", "password"))

OkComputer::Registry.register "elasticsearch", OkComputer::ElasticsearchCheck.new(opensearch_url)
OkComputer::Registry.register "redis", OkComputer::RedisCheck.new(Rails.application.config_for(:redis))
OkComputer::Registry.register "sidekiq", OkComputer::SidekiqLatencyCheck.new(30)
