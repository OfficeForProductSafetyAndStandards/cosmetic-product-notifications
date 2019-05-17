$:.push File.expand_path("lib", __dir__)

Gem::Specification.new do |s|
  s.name        = "shared-web"
  s.version     = "1.0.0"
  s.authors     = %w(UKGovernmentBEIS)
  s.summary     = "Shared functionality for OPSS applications."

  s.add_dependency "active_hash", "2.2.1"
  s.add_dependency "aws-sdk-s3", "1.39.0"
  s.add_dependency "elasticsearch-model", "6.0.0"
  s.add_dependency "elasticsearch-rails", "6.0.0"
  s.add_dependency "govuk_notify_rails", "2.1.0"
  s.add_dependency "keycloak", "2.4.1"
  s.add_dependency "lograge", "0.11.0"
  s.add_dependency "mini_magick", "4.9.3"
  s.add_dependency "okcomputer", "1.17.4"
  s.add_dependency "rails", "5.2.3"
  s.add_dependency "request_store", "1.4.1"
  s.add_dependency "rest-client", "2.0.2"
  s.add_dependency "sentry-raven", "2.9.0"
  s.add_dependency "sidekiq", "5.2.7"
  s.add_dependency "sidekiq-cron", "1.1.0"
  s.add_dependency "slowpoke", "0.2.1"
  s.add_dependency "webpacker", "4.0.2"
  s.add_dependency "will_paginate", "3.1.7"
end
