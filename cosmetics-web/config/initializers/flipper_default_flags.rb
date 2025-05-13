Rails.application.config.after_initialize do
  # Create the two_factor_authentication feature flag if it doesn't exist
  # The flag is enabled by default to maintain backward compatibility

  unless Flipper.exist?(:two_factor_authentication)
    Flipper.enable(:two_factor_authentication)
  end
rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad => e
  # Skip setting default flags when database doesn't exist yet
  # This allows tasks like db:create to run without errors
  Rails.logger.warn "Skipping Flipper initialization: #{e.message}"
end
