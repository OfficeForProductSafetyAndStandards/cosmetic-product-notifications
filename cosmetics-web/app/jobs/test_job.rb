class TestJob < ApplicationJob
  def perform
    UnusedCodeAlerting.alert
    Sidekiq.logger.info "*** JOB RUNNING ***"
  end
end
