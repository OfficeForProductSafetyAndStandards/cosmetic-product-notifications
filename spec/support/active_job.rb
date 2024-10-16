RSpec.configure do |config|
  config.include ActiveJob::TestHelper, :with_test_queue_adapter
  config.around :each, :with_test_queue_adapter do |example|
    ActiveJob::Base.queue_adapter = :test
    example.run
    ActiveJob::Base.queue_adapter = :inline
  end
end
