module QueryHelper
  def build_query
    filtered_query
  end

  def filtered_query
    {
      query: {
        bool: {
          must: match_params,
          filter: filter_params
        }
      }
    }
  end

  def match_params
    if @query.present?
      multi_match
    else
      match_all
    end
  end

  def multi_match
    {
      multi_match: {
        query: @query,
        fuzziness: "AUTO"
      }
    }
  end

  def filter_params
    {
      term: { "state": "notification_complete" }
    }
  end

  def match_all
    {
      match_all: {}
    }
  end
end
