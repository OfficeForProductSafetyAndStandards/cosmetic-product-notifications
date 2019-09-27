module ActiveHashSafeLoadable
  extend ActiveSupport::Concern

  module ClassMethods
    def safe_load(data_to_load, data_name:, retries: 3)
      begin
        self.data = data_to_load
      rescue StandardError => e
        Rails.logger.error "Failed to load #{data_name} (remaining retries #{retries}): #{e.message}"
        self.safe_load(data_to_load, data_name: data_name, retries: retries - 1) if retries.positive?
      end
    end
  end
end
