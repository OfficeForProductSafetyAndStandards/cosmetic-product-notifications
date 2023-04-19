class FeatureFlags
  def self.csv_upload_exact_with_shades_enabled?
    Flipper.enabled?(:csv_upload_exact_with_shades)
  end
end
