class ApplicationJob < ActiveJob::Base
  queue_as :mspsds
end
