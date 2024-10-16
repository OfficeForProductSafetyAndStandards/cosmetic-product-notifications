# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

Rails.application.load_tasks

namespace :test do
  desc "Run all rspec tests"
  task all: :environment do
    sh "bin/rspec --profile"
  end
end
