namespace :cf do
  desc "Run a task on the first CloudFoundry application instance"
  task on_first_instance: :environment do
    instance_index = begin
      JSON.parse(ENV["VCAP_APPLICATION"])["instance_index"]
    rescue StandardError
      nil
    end
    exit(0) unless instance_index.zero?
  end
end
