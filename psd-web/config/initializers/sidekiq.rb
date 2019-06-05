def remove_files_without_attachments_job
  remove_files_without_attachments_job = Sidekiq::Cron::Job.new(
    name: 'remove files not attached to anything, midnight every sunday',
    cron: '0 0 * * 0',
    class: "RemoveFilesWithoutAttachmentsJob"
  )
  unless remove_files_without_attachments_job.save
    Rails.logger.error "***** WARNING - Removing files without attachments was not saved! *****"
    Rails.logger.error remove_files_without_attachments_job.errors.join("; ")
  end
end

def create_log_db_metrics_job
  log_db_metrics_job = Sidekiq::Cron::Job.new(
    name: 'log db metrics, every hour',
    cron: '* * * * *',
    class: 'LogDbMetricsJob',
    queue: 'psd'
  )
  unless log_db_metrics_job.save
    Rails.logger.error "***** WARNING - Log DB metrics job was not saved! *****"
    Rails.logger.error log_db_metrics_job.errors.join("; ")
  end
end


Sidekiq.configure_server do |config|
  config.redis = Rails.application.config_for(:redis_queue)
  remove_files_without_attachments_job
  create_log_db_metrics_job
end

Sidekiq.configure_client do |config|
  config.redis = Rails.application.config_for(:redis_queue)
end
