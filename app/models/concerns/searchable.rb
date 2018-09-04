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
                  type: "icu_collation_keyword"
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

    def self.full_search(query)
      __elasticsearch__.search(query.build_query)
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

    def self.sort_params(params)
      sort_field = params[:sort] + ".sort"
      [{ "#{sort_field}": { order: params[:direction] } }]
    end
  end
end
# rubocop:enable Metrics/BlockLength
