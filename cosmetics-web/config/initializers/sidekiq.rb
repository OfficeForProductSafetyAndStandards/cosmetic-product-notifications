def create_remove_expired_email_verification_keys_job
  remove_expired_responsible_person_keys_job = Sidekiq::Cron::Job.new(
    name: 'remove expired email verification keys, midnight every sunday',
    cron: '0 0 * * 0',
    class: 'RemoveExpiredResponsiblePersonKeysJob',
    queue: 'cosmetics'
  )
  unless remove_expired_responsible_person_keys_job.save
    Rails.logger.error "***** WARNING - Removing expired responsible person keys job was not saved! *****"
    Rails.logger.error remove_expired_responsible_person_keys_job.errors.join("; ")
  end
end

def create_log_db_metrics_job
  log_db_metrics_job = Sidekiq::Cron::Job.new(
    name: 'log db metrics, every hour',
    cron: '0 * * * *',
    class: 'LogDbMetricsJob',
    queue: 'cosmetics'
  )
  unless log_db_metrics_job.save
    Rails.logger.error "***** WARNING - Log DB metrics job was not saved! *****"
    Rails.logger.error log_db_metrics_job.errors.join("; ")
  end
end

Sidekiq.configure_server do |config|
  config.redis = Rails.application.config_for(:redis)
  create_remove_expired_email_verification_keys_job
  create_log_db_metrics_job
end

Sidekiq.configure_client do |config|
  config.redis = Rails.application.config_for(:redis)
end
