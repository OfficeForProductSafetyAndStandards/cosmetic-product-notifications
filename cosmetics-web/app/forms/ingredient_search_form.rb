class IngredientSearchForm < Form
  EXACT_MATCH = "exact_match".freeze
  ANY_MATCH   = "any_match".freeze

  attribute :q
  attribute :exact_or_any_match, default: ANY_MATCH

  def filters_present?
    false
  end
end
