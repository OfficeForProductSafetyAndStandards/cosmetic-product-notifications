class ElasticsearchQuery
  def initialize(keyword, category)
    @keyword = keyword
    @category = category
  end

  def build_query
    {
      query: {
        bool: {
          must: search_query,
          filter: filter_query,
        },
      },
    }
  end

  def search_query
    @keyword.blank? ? match_all_query : multi_match_query
  end

  def match_all_query
    {
      match_all: {},
    }
  end

  def multi_match_query
    {
      multi_match: {
        query: @keyword,
        fuzziness: "AUTO",
      },
    }
  end

  def filter_query
    return if @category.blank?

    [
      {
        nested: {
          path: "components",
          query: {
            bool: {
              should: [
                { term: { "components.display_root_category": @category } },
              ],
            },
          },
        },
      },
    ]
  end
end
