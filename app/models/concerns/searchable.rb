# rubocop:disable Metrics/BlockLength
module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # The following dynamic templates define custom mappings for the major data types
    # that automatically generate appropriate sort fields for each type.
    settings do
      mapping dynamic_templates: [
        {
          strings: {
            match_mapping_type: "string",
            mapping: {
              type: "text",
              fields: {
                sort: {
                  type: "keyword"
                }
              }
            }
          }
        }, {
          numbers: {
            match_mapping_type: "long",
            mapping: {
              "type": "long",
              fields: {
                sort: {
                  type: "long"
                }
              }
            }
          }
        }, {
          dates: {
            match_mapping_type: "date",
            mapping: {
              type: "date",
              fields: {
                sort: {
                  type: "date"
                }
              }
            }
          }
        }, {
          booleans: {
            match_mapping_type: "boolean",
            mapping: {
              type: "boolean",
              fields: {
                sort: {
                  type: "boolean"
                }
              }
            }
          }
        }
      ]
    end

    # "prefix" may be changed to a more appropriate query. For alternatives see:
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/term-level-queries.html
    def self.prefix_search(params, field)
      query = {}
      if params[:query].present?
        query[:query] = {
          prefix: {
            "#{field}": params[:query]
          }
        }
      end
      query[:sort] = sort_params(params) if params[:sort].present?

      __elasticsearch__.search(query)
    end

    def self.fuzzy_search(params)
      query = {}
      query[:query] = query_params(params) if params[:query].present?
      query[:sort] = sort_params(params) if params[:sort].present?

      __elasticsearch__.search(query)
    end

    def self.query_params(params)
      if params[:filter].present?
        filtered_query(fuzzy_match_query(params), filter_params(params))
      else
        fuzzy_match_query(params)
      end
    end

    def self.sort_params(params)
      sort_field = params[:sort] + ".sort"
      [{ "#{sort_field}": { order: params[:direction] } }]
    end

    def self.filter_params(params)
      params[:filter].to_h.map { |field, value| { term: { "#{field}": value } } }
    end

    # "multi_match" searches across all fields, applying fuzzy matching to any text and keyword fields
    def self.fuzzy_match_query(params)
      {
        multi_match: {
          query: params[:query],
          fuzziness: "AUTO"
        }
      }
    end

    def self.filtered_query(query_params, filter_params)
      {
        bool: {
          must: [query_params],
          filter: filter_params
        }
      }
    end
  end
end
# rubocop:enable Metrics/BlockLength
