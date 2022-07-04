module OpenSearchQuery
  class Ingredient
    EXACT_MATCH = "exact_match".freeze
    ANY_MATCH   = "any_match".freeze

    FIELDS = %w[searchable_ingredients].freeze

    def initialize(keyword:, match_type:, from_date:, to_date:)
      @keyword    = keyword
      @match_type = match_type
      @from_date = from_date
      @to_date   = to_date
    end

    def build_query
      {
        query: {
          bool: {
            must: select_query,
            filter: filter_query,
          },
        },
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

    def filter_query
      [
        filter_dates_query,
      ].compact
    end

    def filter_dates_query
      return if @from_date.nil? || @to_date.nil?

      {
        range: {
          notification_complete_at: {
            gte: @from_date,
            lte: @to_date,
          },
        },
      }
    end
  end
end
