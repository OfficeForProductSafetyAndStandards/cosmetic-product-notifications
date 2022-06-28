module OpenSearchQuery
  class Ingredient
    EXACT_MATCH = "exact_match".freeze
    ANY_MATCH   = "any_match".freeze

    FIELDS = %w[searchable_ingredients].freeze

    def initialize(keyword:, match_type:)
      @keyword    = keyword
      @match_type = match_type
    end

    def build_query
      {
        query: select_query,
      }
    end

    def select_query
      {
        ANY_MATCH => any_match_query,
        EXACT_MATCH => exact_match_query,
      }[@match_type]
    end

    def any_match_query
      {
        bool: {
          must: {
            multi_match: {
              query: (@keyword || ""),
              fuzziness: "AUTO",
              fields: FIELDS,
            },
          },
        },
      }
    end

    def exact_match_query
      {
        match_phrase: {
          searchable_ingredients: {
            query: (@keyword || ""),
          },
        },
      }
    end
  end
end
