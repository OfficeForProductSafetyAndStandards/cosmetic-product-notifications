def create_log_db_metrics_job
  log_db_metrics_job = Sidekiq::Cron::Job.new(
    name: "#{ENV['SIDEKIQ_QUEUE'] || 'cosmetics'}: log db metrics, every day at 1 am",
    cron: '0 1 * * *',
    class: 'LogDbMetricsJob',
    queue: ENV["SIDEKIQ_QUEUE"] || "cosmetics"
  )
  unless log_db_metrics_job.save
    Rails.logger.error "***** WARNING - Log DB metrics job was not saved! *****"
    Rails.logger.error log_db_metrics_job.errors.join("; ")
  end
end

Sidekiq.configure_server do |config|
  config.redis = Rails.application.config_for(:redis)
  create_log_db_metrics_job
end

Sidekiq.configure_client do |config|
  config.redis = Rails.application.config_for(:redis)
end
