class FeatureFlags
  def self.recovery_codes_for_existing_users_enabled?(user)
    Flipper.enabled?(:recovery_codes_for_existing_users, user)
  end

  def self.two_factor_authentication_enabled?
    Flipper.enabled?(:two_factor_authentication, nil)
  end
end
