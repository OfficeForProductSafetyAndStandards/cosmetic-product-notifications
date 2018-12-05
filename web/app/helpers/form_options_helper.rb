module FormOptionsHelper
  LEGISLATION_CACHE_KEY = "relevant_legislation".freeze
  HAZARD_TYPES_CACHE_KEY = "hazard_types".freeze
  PRODUCT_TYPES_CACHE_KEY = "product_types".freeze

  def relevant_legislation
    Rails.cache.fetch(LEGISLATION_CACHE_KEY, expires_in: 1.hour) do
      Rails.application.config.legislation_constants["legislation"]&.sort
    end
  end

  def hazard_types
    Rails.cache.fetch(HAZARD_TYPES_CACHE_KEY, expires_in: 1.hour) do
      Rails.application.config.hazard_constants["hazard_type"]&.sort
    end
  end

  def product_types
    Rails.cache.fetch(PRODUCT_TYPES_CACHE_KEY, expires_in: 1.hour) do
      Rails.application.config.product_constants["product_type"]&.sort
    end
  end
end
