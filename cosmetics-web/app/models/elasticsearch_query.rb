class ElasticsearchQuery
  def initialize(keyword:, category:, from_date:, to_date:)
    @keyword   = keyword
    @category  = category
    @from_date = from_date
    @to_date   = to_date
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
    [
      filter_categories_query,
      filter_dates_query,
    ].compact
  end

  def filter_categories_query
    return if @category.blank?

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
    }
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
