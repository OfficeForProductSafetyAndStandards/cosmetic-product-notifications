$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "shared/web/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "shared-web"
  s.version     = Shared::Web::VERSION
  s.authors     = %w(UKGovernmentBEIS)
  s.homepage    = "https://github.com/UKGovernmentBEIS/beis-mspsds"
  s.summary     = "Summary of Shared::Web."
  s.description = "Description of Shared::Web."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.1"

  s.add_development_dependency "sqlite3"
end
