Sidekiq.configure_server do |config|
  config.redis = Rails.application.config_for(:redis)
  remove_empty_attachments_job
end

Sidekiq.configure_client do |config|
  config.redis = Rails.application.config_for(:redis)
end

def remove_empty_attachments_job
  remove_attachments_job = Sidekiq::Cron::Job.new(
    name: 'remove attachments pointing at nothing, midnight every day',
    cron: '0 0 * * 0-6',
    class: "RemoveEmptyAttachmentsJob"
  )
  unless remove_attachments_job.save
    Rails.logger.error "***** WARNING - Removing empty attachments was not saved! *****"
    Rails.logger.error remove_attachments_job.errors
  end
end
