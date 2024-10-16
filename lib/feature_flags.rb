class FeatureFlags
  def self.recovery_codes_for_existing_users_enabled?(user)
    Flipper.enabled?(:recovery_codes_for_existing_users, user)
  end
end
