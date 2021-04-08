# Because reindex job is slow, sidekiq cron is starting it several times
# By creating separate job just for sidekiq cron, we will avoid such a clash
class EnqueueReindexElasticsearchJob < ApplicationJob
  def perform
    ReindexElasticsearchJob.perform_later
  end
end
