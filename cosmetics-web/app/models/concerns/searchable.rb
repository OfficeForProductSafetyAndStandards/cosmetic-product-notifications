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

    # TODO: These lines fix the issue of not updating the updated_at in Elasticsearch.
    # Same issue is pointed out in the following link. We can remove it once that PR is merged.
    # https://github.com/elastic/elasticsearch-rails/pull/703
    after_update do |document|
      document.__elasticsearch__.update_document_attributes updated_at: document.updated_at
    end

    def self.full_search(query)
      # This line makes sure elasticsearch index is recreated before we search
      # It fixes the issue of getting no results the first time case list page is loaded
      # It's only used in dev because it lowers performance and the issue it fixes should be an edge case in production
      __elasticsearch__.refresh_index! if Rails.env.development? || Rails.env.test?
      __elasticsearch__.search(query)
    end
  end
end
# rubocop:enable Metrics/BlockLength
