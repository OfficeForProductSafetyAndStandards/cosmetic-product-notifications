class ElasticsearchQuery
  attr_accessor :query

  def initialize(query)
    @query = query
  end

  def build_query
    return match_all_query if @query.blank?

    multi_match_query
  end

  def multi_match_query
    {
      query: {
        multi_match: {
          query: @query,
          fuzziness: "AUTO"
        }
      }
    }
  end

  def match_all_query
    {
      query: {
        match_all: {}
      }
    }
  end
end
