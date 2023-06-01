class FeatureFlags
  def self.csv_upload_exact_with_shades_enabled?(user)
    Flipper.enabled?(:csv_upload_exact_with_shades, user)
  end
end
