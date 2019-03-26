class ApplicationJob < ActiveJob::Base
  queue_as :psd
end
