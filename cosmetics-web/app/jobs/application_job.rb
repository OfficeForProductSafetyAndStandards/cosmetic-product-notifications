class ApplicationJob < ActiveJob::Base
  queue_as :cosmetics
end
