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
      search_term = {}
      search_term[field] = params[:q].downcase # analyzer indexes records in lowercase
      __elasticsearch__.search({
        query: {
          prefix: search_term
        },
        sort: [
          { "#{params[:sort]}": {order: params[:direction]} }
        ]
      })
    end

    # "multi_match" searches across all fields, applying fuzzy matching to any text and keyword fields
    def self.fuzzy_search(params)
      __elasticsearch__.search({
        query: {
          multi_match: {
            query: params[:q].downcase, # analyzer indexes records in lowercase
            fuzziness: "AUTO"
          }
        },
        sort: [
          { "#{params[:sort]}": {order: params[:direction]} }
        ]
      })
    end
  end
end
