require_relative "lib/support_portal/version"

Gem::Specification.new do |spec|
  spec.name        = "support_portal"
  spec.version     = SupportPortal::VERSION
  spec.authors     = ["Office for Product Safety and Standards"]
  spec.email       = ["opss.enquiries@beis.gov.uk"]
  spec.homepage    = "https://github.com/OfficeForProductSafetyAndStandards/cosmetic-product-notifications"
  spec.summary     = "OSU Support Portal"
  spec.description = "Support portal for OSU support teams to administer SCPN."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org.
  # Set a fake URL here since we're not publishing this engine as a gem.
  spec.metadata["allowed_push_host"] = "https://support.cosmetic-product-notifications.service.gov.uk"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/OfficeForProductSafetyAndStandards/cosmetic-product-notifications"
  spec.metadata["changelog_uri"] = "https://github.com/OfficeForProductSafetyAndStandards/cosmetic-product-notifications/blob/develop/support_portal/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "CHANGELOG.md", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.2.0"

  spec.add_runtime_dependency "govuk-components", "~> 4.0"
  spec.add_runtime_dependency "govuk_design_system_formbuilder", "~> 4.0"
  spec.add_runtime_dependency "rails", ">= 7.0.5"

  spec.add_development_dependency "rspec-rails"
end
