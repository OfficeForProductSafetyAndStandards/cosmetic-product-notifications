return if Sidekiq.server?

OkComputer.mount_at = ENV["HEALTH_CHECK_USERNAME"].present? && ENV["HEALTH_CHECK_PASSWORD"].present? && "health"
OkComputer.require_authentication(ENV.fetch("HEALTH_CHECK_USERNAME", "username"), ENV.fetch("HEALTH_CHECK_PASSWORD", "password"))

OkComputer::Registry.register "elasticsearch", OkComputer::ElasticsearchCheck.new(Rails.application.config_for(:opensearch)[:url])
OkComputer::Registry.register "redis", OkComputer::RedisCheck.new(Rails.application.config_for(:redis))
OkComputer::Registry.register "sidekiq", OkComputer::SidekiqLatencyCheck.new(30)
