module FormOptionsHelper
  LEGISLATION_CACHE_KEY = "relevant_legislation".freeze

  def relevant_legislation
    Rails.cache.fetch(LEGISLATION_CACHE_KEY, expires_in: 1.hour) do
      Rails.application.config.legislation_constants["legislation"]&.sort
    end
  end

  def hazard_types
    Rails.application.config.hazard_constants["hazard_type"]
  end

  def product_categories
    Rails.application.config.product_constants["product_category"]
  end

  def compute_select_options(entities: [], ignore_visibility_restrictions: false)
    select_options = { '': nil }
    entities.each do |entity|
      label = entity.display_name(ignore_visibility_restrictions: ignore_visibility_restrictions)
      select_options[label] = entity.id
    end
    select_options
  end
end
