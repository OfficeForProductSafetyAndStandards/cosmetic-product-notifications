module QueryHelper
  def build_query
    @query.present? ? fuzzy_match : { }
  end

  def fuzzy_match
    {
      query: {
        multi_match: {
          query: @query,
          fuzziness: "AUTO"
        }
      }
    }
  end
end
