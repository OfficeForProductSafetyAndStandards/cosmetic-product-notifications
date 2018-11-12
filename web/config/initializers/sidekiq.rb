Sidekiq.configure_server do |config|
  config.redis = Rails.application.config_for(:redis)
  pg_hero_stats_capture_job = Sidekiq::Cron::Job.new(
    name: 'pgHero stats capture - every 5min',
    cron: '*/5 * * * *',
    class: "DbStatsCaptureJob"
  )

  unless pg_hero_stats_capture_job.save
    Rails.logger.error "***** WARNING - pgHero stats capture job was not saved! *****"
    Rails.logger.error pg_hero_stats_capture_job.errors
  end
end

Sidekiq.configure_client do |config|
  config.redis = Rails.application.config_for(:redis)
end
