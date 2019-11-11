class ApplicationJob < ActiveJob::Base
  queue_as ENV["SIDEKIQ_QUEUE"] || "cosmetics"
end
