class ElasticsearchQuery
  SCORE_SORTING = "score".freeze
  DATE_ASCENDING_SORTING  = "date_ascending".freeze
  DATE_DESCENDING_SORTING = "date_descending".freeze

  # AVAILABLE_SORTING = [SCORE_SORTING, DATE_ASCENDING_SORTING, DATE_DESCENDING_SORTING]
  DEFAULT_SORT = SCORE_SORTING

  def initialize(keyword:, category:, from_date:, to_date:, sort_by:)
    @keyword   = keyword
    @category  = category
    @from_date = from_date
    @to_date   = to_date
    @sort_by   = sort_by.presence || SCORE_SORTING
  end

  def build_query
    {
      query: {
        bool: {
          must: search_query,
          filter: filter_query,
        },
      },
      sort: [
        sort_query,
      ],
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

  def sort_query
    {
      SCORE_SORTING => "_score",
      DATE_ASCENDING_SORTING => { notification_complete_at: { order: :asc } },
      DATE_DESCENDING_SORTING => { notification_complete_at: { order: :desc } },
    }[@sort_by]
  end
end
