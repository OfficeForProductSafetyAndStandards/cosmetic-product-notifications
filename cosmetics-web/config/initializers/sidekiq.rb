def remove_expired_email_verification_keys_job
  remove_expired_email_verification_keys_job = Sidekiq::Cron::Job.new(
    name: 'remove expired email verification keys, midnight every sunday',
    cron: '0 0 * * 0',
    class: 'RemoveExpiredEmailVerificationKeysJob',
    queue: 'cosmetics'
  )
  unless remove_expired_email_verification_keys_job.save
    Rails.logger.error "***** WARNING - Removing expired email verification keys job was not saved! *****"
    Rails.logger.error remove_expired_email_verification_keys_job.errors.join("; ")
  end
end

Sidekiq.configure_server do |config|
  config.redis = Rails.application.config_for(:redis)
  remove_expired_email_verification_keys_job
end

Sidekiq.configure_client do |config|
  config.redis = Rails.application.config_for(:redis)
end
