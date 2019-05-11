Gem::Specification.new do |s|
  s.name        = "shared-web-dev"
  s.version     = "1.0.0"
  s.authors     = %w(UKGovernmentBEIS)
  s.summary     = "Shared development dependencies for OPSS applications."

  # Test & static analysis dependencies
  s.add_dependency "brakeman", "4.5.0"
  s.add_dependency "capybara", "3.18.0"
  s.add_dependency "coveralls", "0.8.23"
  s.add_dependency "govuk-lint", "3.11.1"
  s.add_dependency "rubocop", "0.68.1"
  s.add_dependency "rubocop-performance", "1.2.0"
  s.add_dependency "selenium-webdriver", "3.142.2"
  s.add_dependency "simplecov", "0.16.1"
  s.add_dependency "simplecov-console", "0.4.2"
  s.add_dependency "slim_lint", "0.17.0"

  # Dev improvements & debugging
  s.add_dependency "debase", "0.2.2"
  s.add_dependency "listen", "3.1.5"
  s.add_dependency "ruby-debug-ide", "0.6.1"
  s.add_dependency "solargraph", "0.32.2"
end
