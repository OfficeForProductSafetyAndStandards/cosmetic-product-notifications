# Because reindex job is slow, sidekiq cron is starting it several times
# By creating separate job just for sidekiq cron, we will avoid such a clash
class EnqueueReindexOpensearchJob < ApplicationJob
  def perform
    ReindexOpensearchJob.perform_later
  end
end
