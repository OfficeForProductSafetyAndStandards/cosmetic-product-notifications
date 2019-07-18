Gem::Specification.new do |s|
  s.name        = "shared-web-dev"
  s.version     = "1.0.0"
  s.authors     = %w(UKGovernmentBEIS)
  s.summary     = "Shared development dependencies for OPSS applications."

  # Test & static analysis dependencies
  s.add_dependency "brakeman", "4.5.1"
  s.add_dependency "capybara", "3.26.0"
  s.add_dependency "coveralls", "0.8.23"
  s.add_dependency "govuk-lint", "3.11.2"
  s.add_dependency "rubocop", "0.72.0"
  s.add_dependency "rubocop-performance", "1.4.0"
  s.add_dependency "selenium-webdriver", "3.142.3"
  s.add_dependency "simplecov", "0.16.1"
  s.add_dependency "simplecov-console", "0.5.0"
  s.add_dependency "slim_lint", "0.17.0"

  # Dev improvements & debugging
  s.add_dependency "debase", "0.2.3"
  s.add_dependency "listen", "3.1.5"
  s.add_dependency "ruby-debug-ide", "0.7.0"
  s.add_dependency "solargraph", "0.34.3"
end
