$:.push File.expand_path("lib", __dir__)

Gem::Specification.new do |s|
  s.name        = "shared-web"
  s.version     = "1.0.0"
  s.authors     = %w(UKGovernmentBEIS)
  s.summary     = "Shared functionality for OPSS applications."

  s.add_dependency "aws-sdk-s3"
  s.add_dependency "govuk_notify_rails"
  s.add_dependency "rails", "~> 5.2.1"
  s.add_dependency "sidekiq"
  s.add_dependency "sidekiq-cron"
end
