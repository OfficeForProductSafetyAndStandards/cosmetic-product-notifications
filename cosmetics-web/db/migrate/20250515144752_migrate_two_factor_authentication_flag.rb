class MigrateTwoFactorAuthenticationFlag < ActiveRecord::Migration[7.1]
  def up
    # Simply ensure the flag exists and is enabled by default (for security)
    Flipper.add(:two_factor_authentication) unless Flipper.exist?(:two_factor_authentication)
    Flipper.enable(:two_factor_authentication)
    Rails.logger.debug "Created two_factor_authentication flag (enabled by default)"
  end

  def down
    # No need to revert this migration
  end
end
