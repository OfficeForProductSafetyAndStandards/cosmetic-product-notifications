class TestJob < ApplicationJob
  def perform
    p "*** JOB RUNNING ***"
  end
end
