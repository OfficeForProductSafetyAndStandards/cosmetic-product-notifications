module LegislationHelper
  CACHE_KEY = "relevant_legislation".freeze

  def relevant_legislation
    Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) do
      Rails.application.config.legislation_constants["legislation"]&.sort
    end
  end
end
