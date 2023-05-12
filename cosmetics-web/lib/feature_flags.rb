class FeatureFlags
  def self.csv_upload_exact_with_shades_enabled?(user)
    Flipper.enabled?(:csv_upload_exact_with_shades, user)
  end

  def self.secondary_authentication_recovery_codes_enabled?(user)
    Flipper.enabled?(:secondary_authentication_recovery_codes, user)
  end
end
