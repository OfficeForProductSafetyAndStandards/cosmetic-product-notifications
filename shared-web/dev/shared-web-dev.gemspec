Gem::Specification.new do |s|
  s.name        = "shared-web-dev"
  s.version     = "1.0.0"
  s.authors     = %w(UKGovernmentBEIS)
  s.summary     = "Shared development dependencies for OPSS applications."

  # Test & static analysis dependencies
  s.add_dependency "brakeman"
  s.add_dependency "coveralls"
  s.add_dependency "govuk-lint"
  s.add_dependency "rubocop"
  s.add_dependency "simplecov"
  s.add_dependency "simplecov-console"
  s.add_dependency "slim_lint"
  s.add_dependency "capybara"
  s.add_dependency "selenium-webdriver"

  # Dev improvements & debugging
  s.add_dependency "debase"
  s.add_dependency "listen"
  s.add_dependency "ruby-debug-ide"
  s.add_dependency "solargraph"
end
