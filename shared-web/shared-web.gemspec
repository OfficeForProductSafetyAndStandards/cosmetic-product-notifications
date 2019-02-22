$:.push File.expand_path("lib", __dir__)

Gem::Specification.new do |s|
  s.name        = "shared-web"
  s.version     = "1.0.0"
  s.authors     = %w(UKGovernmentBEIS)
  s.summary     = "Shared functionality for OPSS applications."

  s.add_dependency "active_hash", "2.2.0"
  s.add_dependency "aws-sdk-s3", "1.30.1"
  s.add_dependency "clamby", "1.6.1"
  s.add_dependency "govuk_notify_rails", "2.1.0"
  s.add_dependency "keycloak", "2.4.1"
  s.add_dependency "rails", "~> 5.2"
  s.add_dependency "request_store", "1.4.1"
  s.add_dependency "sidekiq", "5.2.5"
  s.add_dependency "sidekiq-cron", "1.1.0"
  s.add_dependency "webpacker", "4.0.0.rc.7"
end
