# rubocop:disable Metrics/BlockLength
module Shared
  module Web
    module Concerns
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
                    type: "text"
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
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
