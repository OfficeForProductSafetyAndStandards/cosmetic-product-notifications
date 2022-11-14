module NotificationCloner
  # Helps to track notification clone job and acts as wrapper of `Sidekiq::Status` class.
  class JobTracker
    REDIS_HASH_NAME = "notification_cloner_job_tracker".freeze

    def self.save_job_id(notification_id, job_id)
      redis.hset(REDIS_HASH_NAME, notification_id, job_id)
    end

    def self.redis
      @redis ||= ConnectionPool::Wrapper.new(size: 4, timeout: 10) do
        Redis.new(Rails.application.config_for(:redis))
      end
    end

    def initialize(notification_id)
      job_id = redis.hget(REDIS_HASH_NAME, notification_id)
      @sidekiq_status = Sidekiq::Status.status(job_id)
    end

    def success?
      @sidekiq_status == :complete
    end

    def pending?
      %i[queued working].include? @sidekiq_status
    end

    # Please note that retrying is also failed status, as we don't plans to do retries for now
    def failed?
      [:failed, :interrupted, :retrying, nil].include? @sidekiq_status
    end

  private

    def redis
      self.class.redis
    end
  end
end
