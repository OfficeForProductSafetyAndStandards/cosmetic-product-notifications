class ElasticsearchQuery
  attr_accessor :query, :filters, :sorting

  def initialize(query, filters, sorting)
    @query = query
    @filters = filters
    @sorting = sorting
  end

  def build_query(highlighted_fields, fuzzy_fields, exact_fields)
    @fuzzy_fields = fuzzy_fields
    @exact_fields = exact_fields
    search_query = {}
    search_query[:query] = query_params if query.present? || filters.present?
    search_query[:sort] = sort_params if sorting.present?
    search_query[:highlight] = {
      fields: highlighted_fields.map do |f|
        {
          "#{f}": {}
        }
      end
    }

    search_query
  end

private

  def query_params
    if filters.present?
      filtered_query
    else
      fuzzy_match
    end
  end

  def filtered_query
    {
      bool: {
        must: match_params,
        filter: filter_params,
      }
    }
  end

  def match_params
    if query.present?
      fuzzy_match
    else
      match_all
    end
  end

  def filter_params
    filters.map do |field, value|
      {
        bool: { "#{field}": value }
      }
    end
  end

  def sort_params
    sorting.map do |field, direction|
      {
        "#{field}.sort": { order: direction, unmapped_type: "long" }
      }
    end
  end

  # "multi_match" searches across all fields, applying fuzzy matching to any text and keyword fields
  def fuzzy_match
    {
      bool: {
        should: [
          match_exact_fields,
          match_fuzzy_fields
        ]
      }
    }
  end

  def match_exact_fields
    {
      multi_match: {
        query: query,
        fields: @exact_fields,
        type: "phrase"
      }
    }
  end

  def match_fuzzy_fields
    {
      multi_match: {
        query: query,
        fields: @fuzzy_fields,
        fuzziness: "AUTO"
      }
    }
  end

  def match_all
    {
      match_all: {}
    }
  end
end
