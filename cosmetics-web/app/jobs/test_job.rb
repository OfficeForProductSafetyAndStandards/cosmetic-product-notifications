class TestJob < ApplicationJob
  def perform
    Sidekiq.logger.info "*** JOB RUNNING ***"
  end
end
