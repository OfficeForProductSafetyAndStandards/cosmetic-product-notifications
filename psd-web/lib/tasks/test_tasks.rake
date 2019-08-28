require "rails/test_unit/runner"

namespace :test do
  task :without_system_tests => "test:prepare" do
    $: << "test"
    test_files = FileList['test/**/*_test.rb'].exclude('test/system/**/*_test.rb')
    Rails::TestUnit::Runner.run(test_files)
  end
end