module OpenSearchQuery
  class Ingredient
    FIELDS = %w[searchable_ingredients].freeze

    def initialize(keyword:)
      @keyword = keyword
    end

    def build_query
      {
        query: {
          bool: {
            must: search_query,
          },
        },
      }
    end

    def search_query
      {
        multi_match: {
          query: (@keyword || ""),
          fuzziness: "AUTO",
          fields: FIELDS,
        },
      }
    end
  end
end
