namespace :cf do
  desc "Only run on the first application instance"
  task on_first_instance: :environment do
    instance_index = JSON.parse(ENV["VCAP_APPLICATION"])["instance_index"] rescue nil
    exit(0) unless instance_index.zero?
  end
end
