# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
require "login_helpers"
require "domain_helpers"
require "responsible_person_helpers"
require "file_helpers"
require "policy_helpers"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
# Add additional requires below this line. Rails is not loaded until this point!
require "rspec/rails"

require "paper_trail/frameworks/rspec"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [Rails.root.join("spec/fixtures")]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Ensure that any test data or database changes are cleaned up properly between tests
  require "database_cleaner/active_record"

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.before(:each, :js) do
    DatabaseCleaner.strategy = :truncation
  end

  # Include additional helpers and modules
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Capybara::DSL, type: :feature
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include FactoryBot::Syntax::Methods
  config.include DomainHelpers
  config.include FileHelpers
  config.include LoginHelpers
  config.include Matchers
  config.include ResponsiblePersonHelpers
  config.include ActionDispatch::TestProcess::FixtureFile
  config.include DatabaseQueryCounter

  # Reset search indexes before each test if using a search service like Elasticsearch
  config.before do
    Notification.delete_all
    ResponsiblePerson.delete_all
    Notification.import_to_opensearch(force: true) if defined?(Notification.import_to_opensearch)
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Suppress RSpec mock warnings about nil expectations
  config.mock_with :rspec do |mocks|
    mocks.allow_message_expectations_on_nil = true
  end

  config.before(:suite) do
    # Disable verbose logging during tests
    ActiveRecord::Base.logger.level = Logger::INFO
    Rails.logger.level = Logger::INFO
    ActiveJob::Base.logger.level = Logger::INFO
    ActionMailer::Base.logger.level = Logger::INFO

    # Disable all loggers
    ActiveRecord::Base.logger = Logger.new(nil)
    Rails.logger = Logger.new(nil)
    ActiveJob::Base.logger = Logger.new(nil)
    ActionMailer::Base.logger = Logger.new(nil)

    # Disable Elasticsearch/Searchkick logging
    if defined?(Searchkick)
      Searchkick.class_eval do
        def self.warn(*); end
      end
    end
  end
end
